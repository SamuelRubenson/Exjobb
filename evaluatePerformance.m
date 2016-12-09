function [ output ] = evaluatePerformance(Open, High, Low, Close, Config, assetClasses, varargin)
p = inputParser;
p.CaseSensitive = false;

default = false;

addRequired(p, 'Open', @isnumeric);
addRequired(p, 'High', @isnumeric);
addRequired(p, 'Low', @isnumeric);
addRequired(p, 'Close', @isnumeric);
addRequired(p, 'Config', @(A)isa(A,'struct'));
addRequired(p, 'assetClasses', @iscell);
addParameter(p,'TF_ema', default)
addParameter(p,'MV', default)
addParameter(p,'RP', default)
addParameter(p,'RPmod', default)
addParameter(p,'MVRP', default)
addParameter(p,'LES', default)
addParameter(p,'RPLES', default)

parse(p,Open, High, Low, Close, Config, assetClasses, varargin{:});

[T, nMarkets] = size(Close);
output = struct('General', struct, 'Models',struct);

[dZ, sigma_t, corrMat] = initialize();

output.General = struct('std', sigma_t, 'corr', corrMat, 'dZ', dZ);

if isa(p.Results.TF_ema, 'struct')
  runTF_ema(p.Results.TF_ema, p.Results.MV, p.Results.RP, p.Results.RPmod, p.Results.LES);
end
% 
% if isa(p.Results.MV, 'struct')
%   runModel('MV', p.Results.MV);
% end
% 
% if isa(p.Results.RP, 'struct')
%   runModel('RP', p.Results.RP)
% end
% 
% if isa(p.Results.RPmod, 'struct')
%   runModel('RPmod', p.Results.RPmod)
% end
% 
% if isa(p.Results.MVRP, 'struct')
%   runModel('MVRP', p.Results.MVRP)
% end
% 
% if isa(p.Results.LES, 'struct')
%   runLES(p.Results.LES)
% end
% 
% if isa(p.Results.RPLES, 'struct')
%   runRPLES(p.Results.RPLES)
% end

%---------------------------------------------------------------------------
  
  function [dZ, yz, corrMat_tm1] = initialize()
    %disp('Initializing...')
    yzv=yangzhang(cat(3,Open,High,Low,Close), Config.yz_tau);
    yz = sqrt(yzv([1 1:end-1],:));
    dZ = [nan(1,nMarkets) ; diff(lvcf(Close))]./yz;
    corrMat_t = estCorrMat(dZ, Config.cov_tau, Config.cov_filter);
    corrMat_tm1 = cat(3, corrMat_t(:,:,1), corrMat_t(:,:,1:end-1));
  end
  
%---------------------------------------------------------------------------
  
  function [pos] = runTF_ema(paramsTF, paramsMV, paramsRP, paramsRPM, paramsLES)
    %disp('Processing TF-model...')
    TF = []; MV = []; RP = []; RPM = []; LES = [];
    nTau = numel(paramsTF.aLong); LESlambda = linspace(5,12,nTau);
    for iTau = 1:nTau
      paramsTF.aLong(iTau)
      [pos, tau] = getTFpos(dZ, corrMat, paramsTF.aLong(iTau), paramsTF.aShort, Config.target_volatility);
      [sharpe, equityCurve, htime, rev] = indivitualResults(pos, Config.cost, Open, Close, sigma_t, Config.riskAdjust);
      TFres = struct('sharpe', sharpe, 'equityCurve', equityCurve, 'pos', pos, 'htime', htime, 'rev', rev, 'tau', tau);
      TF = [TF; TFres];
      MV = [MV; runModel('MV', paramsMV, pos)];
      RP = [RP; runModel('RP', paramsRP, pos)];
      RPM = [RPM; runModel('RPmod', paramsRPM, pos)];
      LES = [LES; runLES(paramsLES, pos, tau)];
    end
    output.Models.TF = TF;
    output.Models.MV = MV;
    output.Models.RP = RP;
    output.Models.RPmod = RPM;
    output.Models.LES = LES;
  end

%---------------------------------------------------------------------------
  
  function [out] = runModel(model, params, TF_pos)
    fprintf('Processing %s-model...\n',model)
    sharpe=[]; equityCurve=[]; pos=[]; htime = []; meanDraw = [];
    for lambda = params.lambda
      switch model
        case 'MV'
          ipos = getMVpos(TF_pos, corrMat, Config.target_volatility, lambda);
        case 'RP'
          ipos = getRPpos(TF_pos, corrMat, Config.target_volatility, lambda, params.regCoeffs);
        case 'RPmod'
          ipos = getRPMODpos(TF_pos, corrMat, Config.target_volatility, lambda, params.regCoeffs);
        case 'MVRP'
          ipos = getMVRPpos( TF_pos, corrMat, assetClasses,  Config.target_volatility, lambda, params.lambdaRP);
      end
      [sh, eq, ht] = indivitualResults(ipos, Config.cost, Open, Close, sigma_t, Config.riskAdjust);
      MD = nanmean(eq - cummax(eq));
      meanDraw = [meanDraw; MD];
      sharpe = [sharpe; sh]; equityCurve = [equityCurve, eq(:)]; htime = [htime; ht];
    end
    out = struct('sharpe', sharpe, 'equityCurve', equityCurve, 'meanDraw', meanDraw, 'htime', htime, 'lambda', params.lambda);
  end


  function [out] = runLES(params, TF_pos, tau)
    %disp('Processing LES-model...')
    [Q, L] =  ndgrid(params.lookBack, params.lambda);
    sharpe=zeros(size(Q)); equityCurve=[]; equityCurve2=[]; pos=[]; htime = zeros(size(Q)); rev = []; meanDraw = zeros(size(Q)); meanNorm = zeros(size(Q));
    sharpe2=zeros(size(Q)); htime2 = zeros(size(Q)); meanDraw2 = zeros(size(Q));
    nInstances = numel(Q);
    for k = 1:nInstances
      [lookBack, lambda] = deal(Q(k),L(k));
      %ipos = getLESpos(dZ, TF_pos, corrMat, lookBack, Config.target_volatility, beta);
      [ipos, mNorm, dev] = getTESTpos(dZ, TF_pos, corrMat, lookBack, Config.target_volatility, tau, lambda);
      [sh, eq, ht, r] = indivitualResults(ipos, Config.cost, Open, Close, sigma_t, Config.riskAdjust);
      [sh2, eq2, ht2] = indivitualResults(avgPos(ipos), Config.cost, Open, Close, sigma_t, Config.riskAdjust);
      sharpe(k) = sh; htime(k) = ht;
      meanDraw(k) = nanmean(eq - cummax(eq));
      meanNorm(k) = mNorm;
      sharpe2(k) = sh2; htime2(k) = ht2;
      meanDraw2(k) = nanmean(eq2 - cummax(eq2));
      equityCurve = [equityCurve, eq(:)];
      equityCurve2 = [equityCurve2, eq2(:)];
    end
    out = struct('meanDraw2', meanDraw2, 'sharpe2', sharpe2, 'htime2', htime2, 'sharpe', sharpe, 'htime', htime, 'beta', params.beta, 'lookBack', params.lookBack, 'meanDraw', meanDraw, 'meanNorm', meanNorm, 'lambda', params.lambda, 'equityCurve', equityCurve, 'equityCurve2', equityCurve2);%, 'pos', ipos, 'rev', r, 'dev', dev);
  end

%--------------------------------------------------------------------------


end

