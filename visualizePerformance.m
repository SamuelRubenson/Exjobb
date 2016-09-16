function [] = visualizePerformance( outCome, dates, assetClasses )
for i = 1:4, figure(i), clf; end
models = fieldnames(outCome.Models);
sharpe_ratios = zeros(length(models), 1);

drawdowns = zeros(numel(dates), length(models));

for iModel = 1:length(models);
  model_data = outCome.Models.(models{iModel});
  sharpe_ratios(iModel) = model_data.sharpe;
  figure(1), hold on
  plot(dates, model_data.equityCurve)
  drawdowns(:,iModel) = model_data.equityCurve-cummax(model_data.equityCurve);
  hold off
end
figure(1), title('Equity curve'), legend(models)
figure(2), hold on, title('Drawdown'), boxplot(drawdowns, 'Labels', models, 'Notch', 'on')
figure(3), hold on, title('Drawdown'), plot(dates, drawdowns), ylim([1.5*min(min(drawdowns)),0]), legend(models)

figure(4), clf, hold on
bar(sharpe_ratios)
set(gca,'xtick', 1:length(models),'xticklabel', models)
ylabel('Sharpe Ratio')


for iModel=1:length(models)
  model_pos = outCome.Models.(models{iModel}).pos;
  [data,groups] = grpstats(abs(model_pos'),assetClasses',{'sum', 'gname'});
  figure(), title(models{iModel}),hold on
  plot(cumsum(abs(data')./repmat(sum(abs(data'),2),1,length(groups)),2))
  ylim([0,1])
  legend(groups)
  %boxplot(model_pos./repmat(sum(abs(model_pos),2),1,size(model_pos,2)),assetClasses)
end


    

end

