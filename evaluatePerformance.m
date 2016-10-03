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

parse(p,Open, High, Low, Close, Config, assetClasses, varargin{:});

[T, nMarkets] = size(Close);
output = struct('General', struct, 'Models',struct);

[dZ, sigma_t, corrMat] = initialize();

output.General = struct('std', sigma_t, 'corr', corrMat, 'dZ', dZ);

if isa(p.Results.TF_ema, 'struct')
  TF_pos = runTF_ema(p.Results.TF_ema);
end

if isa(p.Results.MV, 'struct')
  runModel('MV', p.Results.MV);
end

if isa(p.Results.RP, 'struct')
  runModel('RP', p.Results.RP)
end

if isa(p.Results.RPmod, 'struct')
  runModel('RPmod', p.Results.RPmod)
end

if isa(p.Results.MVRP, 'struct')
  runModel('MVRP', p.Results.MVRP)
end

if isa(p.Results.LES, 'struct')
  runLES(p.Results.LES)
end

%---------------------------------------------------------------------------
  
  function [dZ, yz, corrMat_tm1] = initialize()
    disp('Initializing...')
    yzv=yangzhang(cat(3,Open,High,Low,Close), Config.yz_tau);
    yz = sqrt(yzv([1 1:end-1],:));
    dZ = [nan(1,nMarkets) ; diff(lvcf(Close))]./yz;
    corrMat_t = estCorrMat(dZ, Config.cov_tau, Config.cov_filter);
    corrMat_tm1 = cat(3, corrMat_t(:,:,1), corrMat_t(:,:,1:end-1));
  end
  
%---------------------------------------------------------------------------
  
  function [pos] = runTF_ema(params)
    disp('Processing TF-model...')
    pos = getTFpos(dZ, corrMat, params.aLong, params.aShort, Config.target_volatility);
    [sharpe, equityCurve, htime, rev] = indivitualResults(pos, Config.cost, Open, Close, sigma_t, Config.riskAdjust);
    output.Models.TF = struct('sharpe', sharpe, 'equityCurve', equityCurve, 'pos', pos, 'htime', htime, 'rev', rev);
  end

%---------------------------------------------------------------------------

  function [] = runModel(model, params)
    fprintf('Processing %s-model...',model)
    switch model
      case 'MV'
        pos = getMVpos(TF_pos, corrMat, params.lambda, Config.target_volatility);
      case 'RP'
        pos = getRPpos(TF_pos, corrMat, Config.target_volatility, params.lambda, params.regCoeffs);
      case 'RPmod'
        pos = getRPMODpos(TF_pos, corrMat, Config.target_volatility, params.lambda, params.regCoeffs);
      case 'MVRP'
        pos = getMVRPpos(TF_pos, corrMat, assetClasses, Config.target_volatility, params.lambdaMV, params.lambdaRP);
    end
    [sharpe, equityCurve, htime, rev] = indivitualResults(pos, Config.cost, Open, Close, sigma_t, Config.riskAdjust);
    output.Models.(model) = struct('sharpe', sharpe, 'equityCurve', equityCurve, 'pos', pos, 'htime', htime, 'rev', rev);
  end


  function [] = runLES(params)
    disp('Processing LES-model...')
    sharpe=[]; equityCurve=[]; pos=[]; htime = [];
    for beta = params.beta
      ipos = getLESpos(dZ, TF_pos, corrMat, params.lookBack, Config.target_volatility, beta);
      [sh, eq, ht] = indivitualResults(ipos, Config.cost, Open, Close, sigma_t, Config.riskAdjust);
      sharpe = [sharpe; sh]; equityCurve = [equityCurve, eq(:)]; pos = cat(3,pos,ipos); htime = [htime; ht];
    end
    output.Models.LES = struct('sharpe', sharpe, 'equityCurve', equityCurve, 'pos', pos, 'htime', htime, 'beta', params.beta);
  end

%--------------------------------------------------------------------------

end

