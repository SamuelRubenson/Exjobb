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
    nTau = numel(paramsTF.aLong);
    for iTau = 1:nTau
      paramsTF.aLong(iTau)
      [pos, tau] = getTFpos(dZ, corrMat, paramsTF.aLong(iTau), paramsTF.aShort, Config.target_volatility);
      [sharpe, equityCurve, htime, rev] = indivitualResults(pos, Config.cost, Open, Close, sigma_t, Config.riskAdjust);
      TFres = struct('sharpe', sharpe, 'equityCurve', equityCurve, 'pos', pos, 'htime', htime, 'rev', rev, 'tau', tau);
      TF = [TF; TFres];
      MV = [MV; runModel('MV', paramsMV, pos)];
      RP = [RP; runModel('RP', paramsRP, pos)];
      RPM = [RPM; runModel('RPmod', paramsRPM, pos)];
      LES = [LES; runLES(paramsLES, pos)];
    end
    output.Models.TF = TF;
    output.Models.MV = MV;
    output.Models.RP = RP;
    output.Models.RPmod = RPM;
    output.Models.LES = LES;
  end

%---------------------------------------------------------------------------

  function [out] = runModel(model, params, TF_pos)
    %fprintf('Processing %s-model...\n',model)
    switch model
      case 'MV'
        pos = getMVpos(TF_pos, corrMat, Config.target_volatility, params.lambda);
      case 'RP'
        pos = getRPpos(TF_pos, corrMat, Config.target_volatility, params.lambda, params.regCoeffs);
      case 'RPmod'
        pos = getRPMODpos(TF_pos, corrMat, Config.target_volatility, params.lambda, params.regCoeffs);
      case 'MVRP'
        pos = getMVRPpos(TF_pos, corrMat, assetClasses, Config.target_volatility, params.lambdaMV, params.lambdaRP);
    end
    [sharpe, eq, htime, rev] = indivitualResults(pos, Config.cost, Open, Close, sigma_t, Config.riskAdjust);
    [sharpe2, eq2, htime2] = indivitualResults(avgPos(pos), Config.cost, Open, Close, sigma_t, Config.riskAdjust);
    meanDraw = nanmean(eq - cummax(eq));
    meanDraw2 = nanmean(eq2 - cummax(eq2));
    out = struct('meanDraw2', meanDraw2, 'sharpe2', sharpe2, 'htime2', htime2, 'sharpe', sharpe, 'meanDraw', meanDraw, 'equityCurve', eq, 'pos', pos, 'htime', htime, 'rev', rev);
  end


  function [out] = runLES(params, TF_pos)
    %disp('Processing LES-model...')
    %ipos = getLESpos(dZ, TF_pos, corrMat, lookBack, Config.target_volatility, beta);
    [pos, meanNorm, dev] = getTESTpos(dZ, TF_pos, corrMat, params.lookBack, Config.target_volatility, params.beta, params.lambda);
    [sharpe, eq, htime, r] = indivitualResults(pos, Config.cost, Open, Close, sigma_t, Config.riskAdjust);
    [sharpe2, eq2, htime2] = indivitualResults(avgPos(pos), Config.cost, Open, Close, sigma_t, Config.riskAdjust);
    meanDraw = nanmean(eq - cummax(eq));
    meanDraw2 = nanmean(eq2 - cummax(eq2));
    out = struct('meanDraw2', meanDraw2, 'sharpe2', sharpe2, 'htime2', htime2, 'sharpe', sharpe, 'htime', htime, 'beta', params.beta, 'lookBack', params.lookBack, 'meanDraw', meanDraw, 'meanNorm', meanNorm, 'lambda', params.lambda, 'equityCurve', eq, 'pos', pos, 'rev', r, 'dev', dev);
  end

%--------------------------------------------------------------------------


end

