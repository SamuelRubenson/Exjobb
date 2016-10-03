% load ContractsToLoad names
%dbc=DBClient('DllPath', 'H:\DBClient');
% [Date, Open, High, Low, Close] = dbc.GetDailyBars(names);
% dates = datetime(Date,'ConvertFrom','datenum');
% save('160830', 'Date', 'Open', 'High', 'Low', 'Close')
%%
addpath(genpath('H:\Exjobb'))
clc, clear
load contractsToLoad names
load assetClasses
load 160830
dates = datetime(Date,'ConvertFrom','datenum');

Config = struct('cost', 0, 'target_volatility', 10, 'riskAdjust', false, 'yz_tau', 60, 'cov_tau', 100, 'cov_filter', 'EMA');

TF_ema_Params = struct('aLong', [], 'aShort', []);
TF = {'TF_ema', TF_ema_Params};

MV_Params = struct('lambda', 0:0.1:2);
MV = {'MV', MV_Params};

RP_Params = struct('lambda', 0:0.1:2, 'regCoeffs', 10^10);
RP = {'RP', RP_Params};

RPmod_Params = struct('lambda', 0:0.1:2, 'regCoeffs', 10^10);
RPM = {'RPmod', RPmod_Params};

MVRP_Params = struct('lambda', 0:0.1:2, 'lambdaRP', 0);
MVRP = {'MVRP', MVRP_Params};

outCome = evaluatePerformance(Open, High, Low, Close, Config, assetClasses, TF{:}, MVRP{:});

visualizePerformance(outCome, dates, assetClasses, Open, Close);

%[1000000 100 10 2 0.5]
%%
% outCome = changeCost(outCome, 0.1, false, Open, Close);
% visualizePerformance(outCome, dates, assetClasses);