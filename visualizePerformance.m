function [] = visualizePerformance( outCome, dates, assetClasses )
fill_between_lines = @(X,Y1,Y2,C) fill( [X fliplr(X)],  [Y1 fliplr(Y2)], C );
colors =[      0,    0.4470,    0.7410;
         0.8500,    0.3250,    0.0980;
         0.9290,    0.6940,    0.1250;
         0.4940,    0.1840,    0.5560;
         0.4660,    0.6740,    0.1880;
         0.3010,    0.7450,    0.9330;
         0.6350,    0.0780,    0.1840];
    
for i = 1:3, figure(i), clf; end
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
figure(2),
subplot(1,2,1), hold on, title('Drawdown'), boxplot(drawdowns, 'Labels', models, 'Notch', 'on')
subplot(1,2,2), hold on
bar(sharpe_ratios)
set(gca,'xtick', 1:length(models),'xticklabel', models)
ylabel('Sharpe Ratio')

%figure(3), hold on, title('Drawdown'), plot(dates, drawdowns), ylim([1.5*min(min(drawdowns)),0]), legend(models)

%figure(4), clf, hold on




figure(3), clf
for iModel=1:length(models)
  model_pos = outCome.Models.(models{iModel}).pos;
  [data,groups] = grpstats(abs(model_pos'),assetClasses',{'sum', 'gname'});
  data(isnan(data)) = 0;
  norm_data = sum(abs(data'),2); norm_data(norm_data==0) = 1;
  plot_data = [zeros(size(data',1),1), cumsum(abs(data')./repmat(norm_data,1,length(groups)),2)];
  subplot(2,2,iModel), title(models{iModel}),hold on
  for iClass = 2:size(plot_data,2)
    jbfill(1:size(plot_data,1), plot_data(:,iClass)', plot_data(:, iClass-1)', colors(iClass-1,:));
  end
  ylim([0,1])
end
legend(groups)

    

end

