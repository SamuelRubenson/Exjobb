function [ ] = visualizePerformance( outCome, index_data )

if nargin<2
  index_data = [];
end

models = fieldnames(outCome);
volatilities = zeros(length(models), 1);

for iModel = 1:length(models);
  model_data = outCome.(models{iModel});
  volatilities(iModel) = std(model_data.portfolio_returns);
  figure(1), hold on
  plot(model_data.times, cumprod(model_data.portfolio_returns + 1))
  hold off
  figure(), hold on
  histogram(model_data.portfolio_returns, floor(length(model_data.portfolio_returns) / 10))
  title(['Portfolio return distribution: ', models{iModel}])
  hold off
  weightsPlot(models{iModel}, model_data)
end

if ~isempty(index_data)
  index_data_to_show = index_data(:);
  index_returns = (index_data_to_show(2:end,:)-index_data_to_show(1:end-1,:))./index_data_to_show(1:end-1,:);
  %index_cum_returns = index_data_to_show/index_data_to_show(1);
  figure(1), hold on
  plot(cumprod(index_returns + 1), '--', 'LineWidth',1)
  legend(models, 'Index'), hold off
  
  figure(), hold on
  histogram(index_returns + 1, floor(length(index_returns)/10))
  title('Index return distribution')
  
  volatilities = [volatilities; std(index_returns)];
  models = {models{:}, 'Index'};
end

figure()
bar(volatilities)
set(gca,'xticklabel', models)
ylabel('\sigma')
title('Portfolio volatility, NOT YET CORRECT NEED DAILY RETURNS? NEED returns not cummulative')


  function [] = weightsPlot(model, model_data)
    weights = model_data.weights;
    times_eval = model_data.times;
    w_sum = sum(weights,2);
    w_abs_sum = sum(abs(weights),2);
    w_sign = sum(sign(weights),2);
    figure(), hold on
    yyaxis left
    plot(times_eval, w_sum, '.-')
    plot(times_eval, w_abs_sum)
    yyaxis right
    plot(times_eval, w_sign)
    legend('Sum of weights', 'Sum of abs weights', 'Sum of sign weights')
    title(['Weights info for model: ', model])
  end

end

