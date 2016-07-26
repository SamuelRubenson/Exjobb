clear, clc
stocks = {'volvo', 'swedbank', 'skf', 'skanska', 'nordea', 'HM', 'ericsson', 'autoliv',...
          'telia', 'tele2', 'SEB', 'SCA', 'sandvik', 'kinnevik', 'investor',...
          'handelsbanken', 'getinge', 'electrolux', 'boliden', 'atlasCopco', 'astraZeneca', ...
          'assaAbloy', 'alphaLaval', 'ABB'};


index = {'OMXS30'};

[struct_data, stocks_matrix_data, index_matrix_data, common_dates] = readTestData(stocks, index);

return_data = ( stocks_matrix_data(2:end,:) - stocks_matrix_data(1:end-1,:) ) ./ stocks_matrix_data(1:end-1,:); 
return_data(abs(return_data) > 0.3) = 0; % Remove stock splits


start = 250;
step = 10;
times_to_evaluate = start:step:size(return_data,1);
store_weights = [];

figure(2),clf
hold on
for k = [0.5 1 2 3]
  for t = times_to_evaluate
    if t>start
      new_capital = sum( w .* prod(return_data(t-step:t,:) + 1 ,1)' * capital(end) );
      capital = [capital; new_capital];
    else
      capital = 1;
    end

    mu = mean(return_data(1:t,:),1);
    sigma = cov(return_data(1:t,:));

    w = MV_Optimize(mu, sigma, k);

    store_weights = [store_weights; w'];
  end
  plot(capital)
end

index_data_to_show = index_matrix_data(times_to_evaluate);
plot(index_data_to_show/index_data_to_show(1),'--', 'LineWidth', 2)
legend('k = 0.5', 'k=1', 'k=2', 'k=3', 'Index')

figure(3), clf
plot(store_weights)
