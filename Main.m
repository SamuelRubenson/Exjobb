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

MV_keys =     {'start', 'step', 'risk_level', 'lookBack_mu', 'lookBack_sigma', 'option'};
MV_values =    { 30,       2,      [50000000],         20,             40,  'LongShort' };
MV_params = containers.Map(MV_keys, MV_values);

outCome = evaluatePerformance(return_data, 'MV', MV_params);

figure(2),clf
hold on
%yyaxis left
plot(outCome.MV.capital)
%yyaxis right
index_data_to_show = index_matrix_data(outCome.MV.times);
plot(index_data_to_show/index_data_to_show(1), '--', 'LineWidth',2)

legend('k = 0.5', 'k=2', 'k=5', 'Index')
%%
figure(3), clf
plot(squeeze(store_weights(:,:,1)))
