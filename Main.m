clear, clc
stocks = {'volvo', 'swedbank', 'skf', 'skanska', 'nordea', 'HM', 'ericsson', 'autoliv',...
          'telia', 'tele2', 'SEB', 'SCA', 'sandvik', 'kinnevik', 'investor',...
          'handelsbanken', 'getinge', 'electrolux', 'boliden', 'atlasCopco', 'astraZeneca', ...
          'assaAbloy', 'alphaLaval', 'ABB'};


index = {'OMXS30'};

[struct_data, stocks_matrix_data, index_matrix_data, common_dates] = readTestData(stocks, index);

return_data = ( stocks_matrix_data(2:end,:) - stocks_matrix_data(1:end-1,:) ) ./ stocks_matrix_data(1:end-1,:); 
return_data(abs(return_data) > 0.3) = 0; % Remove stock splits


start = 30;
step = 10;
times_to_evaluate = start:step:size(return_data,1);
T = length(times_to_evaluate);
risk = [0.5 1 2 3];

store_weights = zeros(T, length(stocks), length(risk));
store_capital = zeros(T,length(risk));

for ik = 1:length(risk)
  k = risk(ik);
  weigths = [];
  fprintf('Processing k = %.1f \n',k)
  for t = times_to_evaluate
    if t>start
      new_capital = sum( w .* prod(return_data(t-step+1:t,:) + 1 ,1)' * capital(end) );
      capital = [capital; new_capital];
    else
      capital = 1;
    end

    mu = mean(return_data(t-start+1:t,:),1);
    sigma = cov(return_data(t-start+1:t,:));

    w = MV_Optimize(mu, sigma, k);

    weigths = [weigths; w'];
  end
  store_capital(:,ik) = capital;
  store_weights(:,:,ik) = weigths;
end

figure(2),clf
hold on
plot(store_capital)
index_data_to_show = index_matrix_data(times_to_evaluate);
plot(index_data_to_show/index_data_to_show(1),'--', 'LineWidth', 2)
legend('k = 0.5', 'k=1', 'k=2', 'k=3', 'Index')
%%
figure(3), clf
plot(squeeze(store_weights(:,:,1)))
