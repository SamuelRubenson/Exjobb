clear, clc
stocks = {'volvo', 'swedbank', 'skf', 'skanska', 'nordea', 'HM', 'ericsson', 'autoliv',...
          'telia', 'tele2', 'SEB', 'SCA', 'sandvik', 'kinnevik', 'investor',...
          'handelsbanken', 'getinge', 'electrolux', 'boliden', 'atlasCopco', 'astraZeneca', ...
          'assaAbloy', 'alphaLaval', 'ABB'};
index = {'OMXS30'};


[struct_data, stocks_matrix_data, index_matrix_data, common_dates] = readTestData(stocks, index);

return_data = ( stocks_matrix_data(2:end,:) - stocks_matrix_data(1:end-1,:) ) ./ stocks_matrix_data(1:end-1,:); 
return_data(abs(return_data) > 0.3) = 0; % Remove stock splits

% start = 40;
% step = 40;
% risk_level = [5000000];

MV_config = {'start', 40, 'step', 20, 'risk_level', [50000000], 'lookBack_mu', 20, 'lookBack_sigma', 40, 'option', 'LongShort'};
MV_params = struct(MV_config{:});

RP_config = {'start', 252, 'step', 20, 'lookBack_sigma', 252, 'lookBack_returns', 252, 'target_volatility', 0.01, 'option', 'VP-TF'};  
RP_params = struct(RP_config{:});

outCome = evaluatePerformance(return_data, 'RP', RP_params);



models = fieldnames(outCome);

figure(2),clf
hold on
for iModel = 1:length(models); plot(outCome.(models{iModel}).capital); end
%yyaxis left

%yyaxis right
index_data_to_show = index_matrix_data(outCome.(models{1}).times);
plot(index_data_to_show/index_data_to_show(1), '--', 'LineWidth',2)

legend(models, 'Index')

