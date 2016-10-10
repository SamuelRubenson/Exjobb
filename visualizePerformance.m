function [] = visualizePerformance( outCome, dates, assetClasses )
nMarkets = numel(assetClasses);
colors =[      0,    0.4470,    0.7410;
         0.8500,    0.3250,    0.0980;
         0.9290,    0.6940,    0.1250;
         0.4940,    0.1840,    0.5560;
         0.4660,    0.6740,    0.1880;
         0.3010,    0.7450,    0.9330;
         0.6350,    0.0780,    0.1840];
    
%for i = 1:3, figure(i), clf; end
models = fieldnames(outCome.Models);
sharpe_ratios = zeros(length(models), 1);
sharpe_index = zeros(length(models), 1);
drawdowns = zeros(numel(dates), length(models));
eqCurves = zeros(numel(dates), length(models));
htimes = zeros(numel(models),1);

figure(1), clf
for iModel = 1:length(models);
  model_data = outCome.Models.(models{iModel});
  [sharpe_ratios(iModel), sharpe_index(iModel)] = max(model_data.sharpe);
  figure(1), hold on
  plot(dates, model_data.equityCurve(:,sharpe_index(iModel)))
  eqCurves(:,iModel) = model_data.equityCurve(:,sharpe_index(iModel));
  drawdowns(:,iModel) = model_data.equityCurve(:,sharpe_index(iModel))-cummax(model_data.equityCurve(:,sharpe_index(iModel)));
  hold off
end
figure(1), title('Equity curve'), legend(models)
figure(2), clf
subplot(1,2,1), hold on, title('Drawdown'), boxplot(drawdowns, 'Labels', models, 'Notch', 'on')
subplot(1,2,2), hold on
bar(sharpe_ratios)
set(gca,'xtick', 1:length(models),'xticklabel', models)
ylabel('Sharpe Ratio')

%figure(3), hold on, title('Drawdown'), plot(dates, drawdowns), ylim([1.5*min(min(drawdowns)),0]), legend(models)

%figure(4), clf, hold on




figure(3), clf
for iModel=1:length(models)
  model_pos = outCome.Models.(models{iModel}).pos(:,:,sharpe_index(iModel));
  [data,groups] = grpstats(abs(model_pos'),assetClasses',{'sum', 'gname'});
  data(isnan(data)) = 0;
  norm_data = sum(abs(data'),2); norm_data(norm_data==0) = 1;%to avoid NaN
  plot_data = [zeros(size(data',1),1), cumsum(abs(data')./repmat(norm_data,1,length(groups)),2)];
  subplot(ceil(numel(models)/2),2,iModel), title(models{iModel}),hold on
  for iClass = 2:size(plot_data,2)
    jbfill(datenum(dates)', plot_data(:,iClass)', plot_data(:, iClass-1)', colors(iClass-1,:));
    xlim([datenum(dates(1)), datenum(dates(end))])
    dynamicDateTicks()
  end
  ylim([0,1])
end
legend(groups)


Q = outCome.General.corr;
figure(4), clf
for iModel = 1:length(models)
  model_pos = outCome.Models.(models{iModel}).pos(:,:,sharpe_index(iModel));
  risk_contributions = nan(size(model_pos));
  for it = 1:size(model_pos,1)
    Qt = Q(:,:,it);
    activeI = logical(any(Qt).*(~isnan(model_pos(it,:))));
    if ~any(activeI), continue; end
    risk_contributions(it,activeI) = model_pos(it,activeI)' .* (Qt(activeI,activeI)*model_pos(it,activeI)');
  end
  [data,groups] = grpstats((risk_contributions'),assetClasses',{'sum', 'gname'});
  data(isnan(data)) = 0;
  norm_data = sum((data'),2); norm_data(norm_data==0) = 1; %to avoid NaN
  plot_data = [zeros(size(data',1),1), cumsum((data')./repmat(norm_data,1,length(groups)),2)];
  subplot(ceil(numel(models)/2),2,iModel), title(models{iModel}),hold on
  for iClass = 2:size(plot_data,2)
    jbfill(datenum(dates)', plot_data(:,iClass)', plot_data(:, iClass-1)', colors(iClass-1,:));
    xlim([datenum(dates(1)), datenum(dates(end))])
    dynamicDateTicks()
  end
  ylim([-0.1,1.1])
end
legend(groups)




%------- Variance in markets compared to TF

% ./repmat(NansumNan(abs(outCome.Models.TF.pos),2),1,nMarkets)
% ./repmat(NansumNan(abs(outCome.Models.(models{iModel}).pos),2),1,nMarkets)
meanVarTF = nanmean(abs(outCome.Models.TF.pos),1);
figure(5), clf
for iModel = 1:length(models)
   meanVarModel = nanmean(abs(outCome.Models.(models{iModel}).pos),1);
   ratios = meanVarModel./meanVarTF;
   subplot(ceil(numel(models)/2),2,iModel), hold on, title(models{iModel})
   bar(ratios/mean(ratios)); %how to scale?
end


%./repmat(NansumNan(abs(outCome.Models.(models{iModel}).pos),2),1,nMarkets)
[meanVarTF, groups] = grpstats(NansumNan(abs(outCome.Models.TF.pos)',2),...
  assetClasses',{'sum', 'gname'}); 
figure(6), clf
for iModel = 1:length(models)
   [meanVarModel, groups] = grpstats(NansumNan(abs(outCome.Models.(models{iModel}).pos)',2),...
     assetClasses',{'sum', 'gname'});
   ratios = meanVarModel./meanVarTF;
   subplot(ceil(numel(models)/2),2,iModel);
   bar(ratios/mean(ratios));
   set(gca,'xtick', 1:length(groups),'xticklabel', groups)
end

% 
% 
% 
% figure(7), clf, hold on, title('Holding times'), xlabel('beta')
% plot(outCome.Models.LES.lookBack, outCome.Models.TF.htime*ones(length(outCome.Models.LES.htime),1))
% plot(outCome.Models.LES.lookBack, outCome.Models.LES.htime);
% legend(models)
% 
% figure(8), clf, hold on, title('Sharpe ratios'), xlabel('Regularization factor')
% plot(outCome.Models.LES.lookBack, outCome.Models.TF.sharpe*ones(length(outCome.Models.LES.sharpe),1))
% plot(outCome.Models.LES.lookBack, outCome.Models.LES.sharpe);
% legend(models)
% 
% 
% figure(9), clf, hold on, title('Mean drawdown')
% plot(outCome.Models.LES.lookBack, nanmean(drawdowns(:,1))*ones(length(outCome.Models.LES.lookBack),1))
% draw = [];
% for iModel = 2:numel(models)
%   draw = [draw, nanmean(outCome.Models.(models{iModel}).equityCurve-cummax(outCome.Models.(models{iModel}).equityCurve,1),1)'];
% end
% plot(outCome.Models.LES.lookBack, draw)
% xlabel('\lambda')
% legend(models)


rollingSharpes = []; years = 1; compareTo = 2;
figure(10), clf, hold on
for iModel = 1:numel(models)
  rollS = rollSharpe(outCome.Models.(models{iModel}).rev, years);
  rollingSharpes = [rollingSharpes, rollS(:)];
end

n = numel(models); 
for iModel = 1:n
if iModel~=compareTo;
subplot(ceil((n-1)/2),2,double(iModel - (iModel>compareTo))), title(sprintf('%s vs %s, Rolling %d-year Sharpe',models{iModel}, models{compareTo}, years))
difff = (rollingSharpes(:,iModel)-rollingSharpes(:,compareTo));
lower = difff.*(difff<=0); lower(isnan(lower)) = 0;
upper = difff.*(difff>0); upper(isnan(upper)) = 0;
jbfill(datenum(dates)',zeros(numel(dates),1)',lower','r');
jbfill(datenum(dates)', upper', zeros(numel(dates),1)', 'g');
xlim([datenum(dates(1)), datenum(dates(end))])
ylim([-1.75,1.75])
dynamicDateTicks()
ylabel('Rolling Sharp difference')
end
end

tmp = [];
for iModel = 1:numel(models)
  tmp = [tmp; sparsness(outCome.Models.(models{iModel}).pos, 5)];
end
figure(), bar(tmp), set(gca,'xtick', 1:length(models),'xticklabel', models)




%---------------------- Model-CORR

rev = diff(eqCurves,1);
%ind = all(~isnan(rev),2);
corrplot(rev, 'rows', 'complete', 'varname', models)

% ----------------------------
  


% figure(10), clf, hold on, title('Quantile drawdown')
% sd = sort(drawdowns(:,1));
% plot(outCome.Models.LES.lookBack, sd(5)*ones(length(outCome.Models.LES.lookBack),1))
% draw = outCome.Models.(models{iModel}).equityCurve-cummax(outCome.Models.(models{iModel}).equityCurve,1);
% val = [];
% for i = 1:size(draw,2)
%   data = draw(:,i);
%   sd = sort(data(~isnan(data)));
%   val = [val; sd(5)];
% end
% plot(outCome.Models.LES.lookBack, val)
% xlabel('\lambda')
% legend(models)

end

