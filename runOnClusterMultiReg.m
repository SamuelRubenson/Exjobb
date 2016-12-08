function [out] = runOnClusterMultiReg()

ac = load('assetClasses');
data = load('160830');

assetClasses = ac.assetClasses;
Open = data.Open;
Close = data.Close;
High = data.High;
Low = data.Low;

lambda = 0.1:0.1:1;
yz_taus = 15:60;

TF_ema_Params = struct('aLong', 200, 'aShort', []);
TF = {'TF_ema', TF_ema_Params};

MV_Params = struct('lambda', lambda);
MV = {'MV', MV_Params};

RP_Params = struct('lambda', lambda, 'regCoeffs', 10^10);
RP = {'RP', RP_Params};

RPmod_Params = struct('lambda', lambda, 'regCoeffs', 10^10);
RPM = {'RPmod', RPmod_Params};

LES_Params = struct('lookBack', 290, 'beta', -0.5, 'lambda', lambda);
LES = {'LES', LES_Params};

%nRuns = 1000;
nRuns = numel(yz_taus);
nL = numel(lambda);

MV_sharpe = zeros(nRuns,nL); RP_sharpe = zeros(nRuns,nL); RPM_sharpe = zeros(nRuns,nL); LES_sharpe = zeros(nRuns,nL);
MV_MD = zeros(nRuns,nL); RP_MD = zeros(nRuns,nL); RPM_MD = zeros(nRuns,nL); LES_MD = zeros(nRuns,nL);
MV_ht = zeros(nRuns,nL); RP_ht = zeros(nRuns,nL); RPM_ht = zeros(nRuns,nL); LES_ht = zeros(nRuns,nL);
MV_at = zeros(nRuns,nL); RP_at = zeros(nRuns,nL); RPM_at = zeros(nRuns,nL); LES_at = zeros(nRuns,nL);

LES_sharpe2 = zeros(nRuns,nL); LES_MD2 = zeros(nRuns,nL); LES_ht2 = zeros(nRuns,nL); LES_at2 = zeros(nRuns,nL); LES_meanNorm = zeros(nRuns,nL);

TF_sharpe = zeros(nRuns,1); TF_MD = zeros(nRuns,1); TF_ht = zeros(nRuns,1); TF_at = zeros(nRuns,1);

store_yz = zeros(nRuns,1);
store_cov_tau = zeros(nRuns,1);
 
%parfor ip = 1:nRuns
  %yz = 15 + randi(45);
  %c_tau = 80 + randi(100);

c_tau = 100;
parfor ip = 1:numel(yz_taus)
  yz = yz_taus(ip);
  
  Config = struct('cost', 0, 'target_volatility', 10, 'riskAdjust', false, 'yz_tau', yz, 'cov_tau', c_tau, 'cov_filter', 'avgEMA');
  outCome = evaluatePerformance(Open, High, Low, Close, Config, assetClasses, TF{:}, MV{:}, RP{:}, RPM{:}, LES{:});
  
  TF_sharpe(ip) = outCome.Models.TF.sharpe;
  MV_sharpe(ip,:) = outCome.Models.MV.sharpe;
  RP_sharpe(ip,:) = outCome.Models.RP.sharpe;
  RPM_sharpe(ip,:) = outCome.Models.RPmod.sharpe;
  LES_sharpe(ip,:) = outCome.Models.LES.sharpe;
  LES_sharpe2(ip,:) = outCome.Models.LES.sharpe2;
  
  TF_MD(ip) = outCome.Models.TF.meanDraw;
  MV_MD(ip,:) = outCome.Models.MV.meanDraw;
  RP_MD(ip,:) = outCome.Models.RP.meanDraw;
  RPM_MD(ip,:) = outCome.Models.RPmod.meanDraw;
  LES_MD(ip,:) = outCome.Models.LES.meanDraw;
  LES_MD2(ip,:) = outCome.Models.LES.meanDraw2;
  
  TF_ht(ip) = outCome.Models.TF.htime;
  MV_ht(ip,:) = outCome.Models.MV.htime;
  RP_ht(ip,:) = outCome.Models.RP.htime;
  RPM_ht(ip,:) = outCome.Models.RPmod.htime;
  LES_ht(ip,:) = outCome.Models.LES.htime;
  LES_ht2(ip,:) = outCome.Models.LES.htime2;
  
  TF_at(ip) = outCome.Models.TF.avgTrade;
  MV_at(ip,:) = outCome.Models.MV.avgTrade;
  RP_at(ip,:) = outCome.Models.RP.avgTrade;
  RPM_at(ip,:) = outCome.Models.RPmod.avgTrade;
  LES_at(ip,:) = outCome.Models.LES.avgTrade;
  LES_at2(ip,:) = outCome.Models.LES.avgTrade2;
  
  LES_meanNorm(ip,:) = outCome.Models.LES.meanNorm;
  
  store_yz(ip) = yz;
  store_cov_tau(ip) = c_tau;
  %disp('.')
end

out = struct;
out.TF = struct('sharpe', TF_sharpe, 'meanDraw', TF_MD, 'htime', TF_ht, 'avgTrade', TF_at);
out.MV = struct('sharpe', MV_sharpe, 'meanDraw', MV_MD, 'htime', MV_ht, 'avgTrade', MV_at);
out.RP = struct('sharpe', RP_sharpe, 'meanDraw', RP_MD, 'htime', RP_ht, 'avgTrade', RP_at);
out.RPmod = struct('sharpe', RPM_sharpe, 'meanDraw', RPM_MD, 'htime', RPM_ht, 'avgTrade', RPM_at);
out.LES = struct('sharpe', LES_sharpe, 'meanDraw', LES_MD, 'htime', LES_ht, 'avgTrade', LES_at,...
              'sharpe2', LES_sharpe2, 'meanDraw2', LES_MD2, 'htime2', LES_ht2, 'avgTrade2', LES_at2, 'meanNorm', LES_meanNorm);
out.yz = store_yz;
out.cov_tau = store_cov_tau;


end