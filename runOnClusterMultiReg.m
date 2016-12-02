function [out] = runOnClusterMultiReg()

ac = load('assetClasses');
data = load('160830');

assetClasses = ac.assetClasses;
Open = data.Open;
Close = data.Close;
High = data.High;
Low = data.Low;

lambda = 0:0.1:1;

TF_ema_Params = struct('aLong', 130, 'aShort', []);
TF = {'TF_ema', TF_ema_Params};

MV_Params = struct('lambda', lambda);
MV = {'MV', MV_Params};

RP_Params = struct('lambda', lambda, 'regCoeffs', 10^10);
RP = {'RP', RP_Params};

RPmod_Params = struct('lambda', lambda, 'regCoeffs', 10^10);
RPM = {'RPmod', RPmod_Params};

% MVRP_Params = struct('lambda', 0:0.1:2, 'lambdaRP', 0);
% MVRP = {'MVRP', MVRP_Params};
nRuns = 1000;
nL = numel(lambda);

MV_sharpe = zeros(nRuns,nL); RP_sharpe = zeros(nRuns,nL); RPM_sharpe = zeros(nRuns,nL);
MV_MD = zeros(nRuns,nL); RP_MD = zeros(nRuns,nL); RPM_MD = zeros(nRuns,nL);
MV_ht = zeros(nRuns,nL); RP_ht = zeros(nRuns,nL); RPM_ht = zeros(nRuns,nL);
MV_at = zeros(nRuns,nL); RP_at = zeros(nRuns,nL); RPM_at = zeros(nRuns,nL);

TF_sharpe = zeros(nRuns,1); TF_MD = zeros(nRuns,1); TF_ht = zeros(nRuns,1); TF_at = zeros(nRuns,1);

store_yz = zeros(nRuns,1);
store_cov_tau = zeros(nRuns,1);
 
parfor ip = 1:nRuns
  yz = 20 + randi(40);
  c_tau = 80 + randi(100);
  
  Config = struct('cost', 0, 'target_volatility', 10, 'riskAdjust', false, 'yz_tau', yz, 'cov_tau', c_tau, 'cov_filter', 'avgEMA');
  outCome = evaluatePerformance(Open, High, Low, Close, Config, assetClasses, TF{:}, MV{:}, RP{:}, RPM{:});
  
  TF_sharpe(ip) = outCome.Models.TF.sharpe;
  MV_sharpe(ip,:) = outCome.Models.MV.sharpe;
  RP_sharpe(ip,:) = outCome.Models.RP.sharpe;
  RPM_sharpe(ip,:) = outCome.Models.RPmod.sharpe;
  
  TF_MD(ip) = outCome.Models.TF.meanDraw;
  MV_MD(ip,:) = outCome.Models.MV.meanDraw;
  RP_MD(ip,:) = outCome.Models.RP.meanDraw;
  RPM_MD(ip,:) = outCome.Models.RPmod.meanDraw;
  
  TF_ht(ip) = outCome.Models.TF.htime;
  MV_ht(ip,:) = outCome.Models.MV.htime;
  RP_ht(ip,:) = outCome.Models.RP.htime;
  RPM_ht(ip,:) = outCome.Models.RPmod.htime;
  
  TF_at(ip) = outCome.Models.TF.avgTrade;
  MV_at(ip,:) = outCome.Models.MV.avgTrade;
  RP_at(ip,:) = outCome.Models.RP.avgTrade;
  RPM_at(ip,:) = outCome.Models.RPmod.avgTrade;
  
  store_yz(ip) = yz;
  store_cov_tau(ip) = c_tau;
  disp('.')
end

out = struct;
out.TF = struct('sharpe', TF_sharpe, 'meanDraw', TF_MD, 'htime', TF_ht, 'avgTrade', TF_at);
out.MV = struct('sharpe', MV_sharpe, 'meanDraw', MV_MD, 'htime', MV_ht, 'avgTrade', MV_at);
out.RP = struct('sharpe', RP_sharpe, 'meanDraw', RP_MD, 'htime', RP_ht, 'avgTrade', RP_at);
out.RPmod = struct('sharpe', RPM_sharpe, 'meanDraw', RPM_MD, 'htime', RPM_ht, 'avgTrade', RPM_at);
out.yz = store_yz;
out.cov_tau = store_cov_tau;


end