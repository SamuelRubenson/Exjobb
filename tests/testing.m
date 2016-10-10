addpath(genpath('/Users/Samuel/Documents/Exjobb'))

clear, clc, close all
stocks = {};
index = {'OMXS30'};

[struct_data, stocks_matrix_data, index_matrix_data, common_dates] = readTestData(stocks, index);
index_matrix_data = flip(index_matrix_data);
[signals_t, sigma_t, z_t] = getSignals(index_matrix_data); 
z_t(1:10)
figure(1), hold on
yyaxis left
plot(1:length(index_matrix_data), index_matrix_data)
yyaxis right
plot(2:length(index_matrix_data), signals_t)
plot([0 length(index_matrix_data)], [0 0])