addpath(genpath('/Users/Samuel/Documents/Exjobb'))

clear, clc, close all
stocks = {'volvo', 'swedbank', 'skf', 'skanska', 'nordea', 'HM', 'ericsson', 'autoliv',...
          'telia', 'tele2', 'SEB', 'SCA', 'sandvik', 'kinnevik', 'investor',...
          'handelsbanken', 'getinge', 'electrolux', 'boliden', 'atlasCopcoA', 'atlasCopcoB', 'astraZeneca', ...
          'assaAbloy', 'alphaLaval', 'ABB', 'securitas', 'lundin', 'swedishMatch', 'SSAB', 'nokia', 'fing'};
index = {'OMXS30'};
% index_weights = [4.56, 5.41, 2.1, 1.55, 10.6, 11.94, 6.85, 0, 5.54, 1.17, 5.56, 3.22, ...
%   3.24, 1.67, 3.81, 5.91, 1.11, 1.85, 1.22, 5.38, 2.23, 2.09, 4.19, 1.61, 2.55, 1.07, 1.03, 1.27, 0.38, 0.13, 0.69]/100;

[struct_data, stocks_matrix_data, index_matrix_data, common_dates] = readTestData(stocks, index);
 
return_data = ( stocks_matrix_data(2:end,:) - stocks_matrix_data(1:end-1,:) ) ./ stocks_matrix_data(1:end-1,:); 
return_data(abs(return_data) > 0.3) = 0; % Remove stock splits
common_dates = common_dates(2:end);

MV_config = {'start', 252, 'step', 10, 'risk_level', [50000000], 'lookBack_mu', 20, 'lookBack_sigma', 40, 'option', 'LongShort'};
MV = {'MV', struct(MV_config{:}) };

RP_config = {'start', 252, 'step', 20, 'lookBack_sigma', 250, 'lookBack_returns', 20, 'target_volatility', 0.3, 'option', 'VP-TF'};  
RP = {'RP', struct(RP_config{:}) };

outCome = evaluatePerformance(return_data, MV{:}, RP{:});

visualizePerformance(outCome, index_matrix_data)

