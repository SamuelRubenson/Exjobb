% load ContractsToLoad names
% dbc=DBClient('DllPath', 'H:\DBClient');
% [Date, Open, High, Low, Close] = dbc.GetDailyBars(names);
% dates = datetime(Date,'ConvertFrom','datenum');
% save('160830', 'Date', 'Open', 'High', 'Low', 'Close')
%%
clc, clear, close all
load ContractsToLoad names
load 160830
dates = datetime(Date,'ConvertFrom','datenum');

Config = struct('cost', 0, 'yz_tau', 60, 'cov_tau', 100, 'cov_filter', 'dEMA');

TF_ema_Params = struct('aLong', [], 'aShort', []);
TF = {'TF_ema', TF_ema_Params};

MV_Params = struct('lambda', 0.5);
MV = {'MV', MV_Params};

RP_Params = struct('target_volatility', 1);
RP = {'RP', RP_Params};

outCome = evaluatePerformance(Open, High, Low, Close, Config, TF{:}, MV{:});

visualizePerformance(outCome, dates);


