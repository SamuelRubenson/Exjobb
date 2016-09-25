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

output.General = struct('std', sigma_t, 'corr', corrMat);

if isa(p.Results.TF_ema, 'struct')
  TF_pos = runTF_ema(p.Results.TF_ema);
end

if isa(p.Results.MV, 'struct')
  runMV(p.Results.MV);
end

if isa(p.Results.RP, 'struct')
  runRP(p.Results.RP)
end

if isa(p.Results.RPmod, 'struct')
  runRPMOD(p.Results.RPmod)
end

if isa(p.Results.MVRP, 'struct')
  runMVRP(p.Results.MVRP)
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
    [sharpe, equityCurve, htime] = indivitualResults(pos, Config.cost, Open, Close, sigma_t, Config.riskAdjust);
    output.Models.TF = struct('sharpe', sharpe, 'equityCurve', equityCurve, 'pos', pos, 'htime', htime);
  end

%---------------------------------------------------------------------------

  function [] = runMV(params)
    disp('Processing MV-model...')
    pos = getMVpos(TF_pos, corrMat, Config.target_volatility, params.lambda);
    [sharpe, equityCurve, htime] = indivitualResults(pos, Config.cost, Open, Close, sigma_t, Config.riskAdjust);
    output.Models.MV = struct('sharpe', sharpe, 'equityCurve', equityCurve, 'pos', pos, 'htime', htime);
  end

%--------------------------------------------------------------------------

  function [] = runRP(params)
    disp('Processing RP-model...')
    pos = getRPpos(TF_pos, corrMat, Config.target_volatility, params.lambda, params.regCoeffs);
    [sharpe, equityCurve, htime] = indivitualResults(pos, Config.cost, Open, Close, sigma_t, Config.riskAdjust);
    output.Models.RP = struct('sharpe', sharpe, 'equityCurve', equityCurve, 'pos', pos, 'htime', htime);
  end
%--------------------------------------------------------------------------

  function [] = runRPMOD(params)
    disp('Processing RPmod-model...')
    pos = getRPMODpos(TF_pos, corrMat, Config.target_volatility, params.lambda, params.regCoeffs);
    [sharpe, equityCurve, htime] = indivitualResults(pos, Config.cost, Open, Close, sigma_t, Config.riskAdjust);
    output.Models.RPmod = struct('sharpe', sharpe, 'equityCurve', equityCurve, 'pos', pos, 'htime', htime);
  end

%--------------------------------------------------------------------------

  function [] = runMVRP(params)
    disp('Processing MVRP-model...')
    pos = getMVRPpos(TF_pos, corrMat, assetClasses, Config.target_volatility, params.lambdaMV, params.lambdaRP);
    %pos = getTESTpos(dZ, TF_pos, corrMat, assetClasses, Config.target_volatility, params.lambda);
    [sharpe, equityCurve, htime] = indivitualResults(pos, Config.cost, Open, Close, sigma_t, Config.riskAdjust);
    output.Models.MVRP = struct('sharpe', sharpe, 'equityCurve', equityCurve, 'pos', pos, 'htime', htime);
  end

%--------------------------------------------------------------------------


end

