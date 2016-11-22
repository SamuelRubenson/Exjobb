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
  
  function [] = runTF_ema(paramsTF, paramsMV, paramsRP, paramsRPM, paramsLES)
    %disp('Processing TF-model...')
    nTau = numel(paramsTF.aLong); LESlambda = linspace(5,12,nTau);
    TF = struct('sharpe', cell(nTau,1), 'equityCurve', cell(nTau,1), 'pos', cell(nTau,1), 'htime', cell(nTau,1), 'rev', cell(nTau,1), 'tau', cell(nTau,1)); 
    MV = struct('meanDraw2', cell(nTau,1), 'sharpe2', cell(nTau,1), 'htime2', cell(nTau,1), 'sharpe', cell(nTau,1), 'meanDraw', cell(nTau,1), 'equityCurve', cell(nTau,1), 'pos', cell(nTau,1), 'htime', cell(nTau,1), 'rev', cell(nTau,1));
    RP = struct('meanDraw2', cell(nTau,1), 'sharpe2', cell(nTau,1), 'htime2', cell(nTau,1), 'sharpe', cell(nTau,1), 'meanDraw', cell(nTau,1), 'equityCurve', cell(nTau,1), 'pos', cell(nTau,1), 'htime', cell(nTau,1), 'rev', cell(nTau,1)); 
    RPM = struct('meanDraw2', cell(nTau,1), 'sharpe2', cell(nTau,1), 'htime2', cell(nTau,1), 'sharpe', cell(nTau,1), 'meanDraw', cell(nTau,1), 'equityCurve', cell(nTau,1), 'pos', cell(nTau,1), 'htime', cell(nTau,1), 'rev', cell(nTau,1));
    LES = struct('meanDraw2', cell(nTau,1), 'sharpe2', cell(nTau,1), 'htime2', cell(nTau,1), 'sharpe', cell(nTau,1), 'htime', cell(nTau,1), 'beta', cell(nTau,1), 'lookBack', cell(nTau,1), 'meanDraw', cell(nTau,1), 'meanNorm', cell(nTau,1), 'lambda', cell(nTau,1), 'equityCurve', cell(nTau,1), 'pos', cell(nTau,1), 'rev', cell(nTau,1), 'dev', cell(nTau,1));
    
    parfor iTau = 1:nTau
      paramsTF.aLong(iTau)
      [pos, tau] = getTFpos(dZ, corrMat, paramsTF.aLong(iTau), paramsTF.aShort, 10);
      [sharpe, equityCurve, htime, rev] = indivitualResults(pos, 0, Open, Close, sigma_t, false);
      TFres = struct('sharpe', sharpe, 'equityCurve', equityCurve, 'pos', pos, 'htime', htime, 'rev', rev, 'tau', tau);
      TF(iTau) = TFres;
      MV(iTau) = runModel('MV', paramsMV, pos, corrMat, Config, sigma_t, Open, Close);
      RP(iTau) = runModel('RP', paramsRP, pos, corrMat, Config, sigma_t, Open, Close);
      RPM(iTau) = runModel('RPmod', paramsRPM, pos, corrMat, Config, sigma_t, Open, Close);
      LES(iTau) = runLES(paramsLES, pos, tau, LESlambda(iTau), dZ, corrMat, Config, sigma_t, Open, Close);
    end
    output.Models.TF = TF;
    output.Models.MV = MV;
    output.Models.RP = RP;
    output.Models.RPmod = RPM;
    output.Models.LES = LES;
  end

end
%---------------------------------------------------------------------------

  function [out] = runModel(model, params, TF_pos, corrMat, Config, sigma_t, Open, Close)
    %fprintf('Processing %s-model...\n',model)
    switch model
      case 'MV'
        pos = getMVpos(TF_pos, corrMat, Config.target_volatility, params.lambda, assetClasses);
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


  function [out] = runLES(params, TF_pos, tau, testLambda, dZ, corrMat, Config, sigma_t, Open, Close)
    %disp('Processing LES-model...')
    %ipos = getLESpos(dZ, TF_pos, corrMat, lookBack, Config.target_volatility, beta);
    [pos, meanNorm, dev] = getTESTpos(dZ, TF_pos, corrMat, params.lookBack, Config.target_volatility, tau, testLambda);
    [sharpe, eq, htime, r] = indivitualResults(pos, Config.cost, Open, Close, sigma_t, Config.riskAdjust);
    [sharpe2, eq2, htime2] = indivitualResults(avgPos(pos), Config.cost, Open, Close, sigma_t, Config.riskAdjust);
    meanDraw = nanmean(eq - cummax(eq));
    meanDraw2 = nanmean(eq2 - cummax(eq2));
    out = struct('meanDraw2', meanDraw2, 'sharpe2', sharpe2, 'htime2', htime2, 'sharpe', sharpe, 'htime', htime, 'beta', params.beta, 'lookBack', params.lookBack, 'meanDraw', meanDraw, 'meanNorm', meanNorm, 'lambda', params.lambda, 'equityCurve', eq, 'pos', pos, 'rev', r, 'dev', dev);
  end

%--------------------------------------------------------------------------


