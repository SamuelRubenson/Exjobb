% load ContractsToLoad names
% dbc=DBClient('DllPath', 'H:\DBClient');
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

MV_Params = struct('lambda', 0.5);
MV = {'MV', MV_Params};

RP_Params = struct('lambda', 0.5, 'regCoeffs', 10^10);
RP = {'RP', RP_Params};

RPmod_Params = struct('lambda', 0.5, 'regCoeffs', 10^10);
RPM = {'RPmod', RPmod_Params};

LES_Params = struct('lookBack', 252, 'beta', 0.85);
LES = {'LES', LES_Params};

RPLES_Params = struct;
RPLES = {'RPLES', RPLES_Params};

start = 1; X = 1:74;% [1:3, 6:9, 11, 14 ,22:23, 26, 4, 10, 16:18 27, 29, 34, 37, 40, 41:42, 5, 13, 15, 21, 25, 31, 63:68, 12, 19, 20, 24, 28, 32, 33, 35, 36, 38, 43:44];
outCome = evaluatePerformance(Open(start:end,X), High(start:end,X), Low(start:end,X), Close(start:end,X), Config, assetClasses(X), TF{:}, MV{:}, RP{:}, RPM{:}, LES{:}, RPLES{:});

visualizePerformance(outCome, dates(start:end), assetClasses(X));

%[1000000 100 10 2 0.5]
%%
% outCome = changeCost(outCome, 0.1, false, Open, Close);
% visualizePerformance(outCome, dates, assetClasses);