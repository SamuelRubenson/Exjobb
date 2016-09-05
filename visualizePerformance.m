function [] = visualizePerformance( outCome, dates )

models = fieldnames(outCome);
sharpe_ratios = zeros(length(models), 1);

drawdowns = zeros(numel(dates), length(models));

for iModel = 1:length(models);
  model_data = outCome.(models{iModel});
  sharpe_ratios(iModel) = model_data.sharpe;
  figure(1), hold on
  plot(dates, model_data.equityCurve)
  drawdowns(:,iModel) = model_data.equityCurve-cummax(model_data.equityCurve);
  hold off
end
figure(1), title('Equity curve'), legend(models)
figure(2), hold on, title('Drawdown'), boxplot(drawdowns, 'Labels', models, 'Notch', 'on')


figure(3), clf, hold on
bar(sharpe_ratios)
set(gca,'xtick', 1:length(models),'xticklabel', models)
ylabel('Sharpe Ratio')


end

