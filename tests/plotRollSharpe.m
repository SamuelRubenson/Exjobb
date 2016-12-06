%% Plot RP+RPmod vs MV

models = fieldnames(outCome.Models);
rollingSharpes = []; years = 1; 
rollingMeans = [];
rollingSTDs = [];

for iModel = 1:numel(models)
  [rollS, rollMu, rollStd] = rollSharpe(outCome.Models.(models{iModel}).rev, years);
  rollingSharpes = [rollingSharpes, rollS(:)];
  rollingMeans = [rollingMeans, rollMu];
  rollingSTDs = [rollingSTDs, rollStd];
end


figure(1), clf, hold on
subplot(2,1,1), box on
difff = (rollingSharpes(:,3)-rollingSharpes(:,2));
lower = difff.*(difff<=0); lower(isnan(lower)) = 0;
upper = difff.*(difff>0); upper(isnan(upper)) = 0;
jbfill(datenum(dates)',zeros(numel(dates),1)',lower','r');
jbfill(datenum(dates)', upper', zeros(numel(dates),1)', 'g');
xlim([datenum(dates(1)), datenum(dates(end))])
ylim([-1.75,1.75])
dynamicDateTicks()
ylabel('Rolling Sharp difference')
title(sprintf('%s vs %s, Rolling %d-year Sharpe. Integral: %.1f',models{3}, models{2}, years, NansumNan(difff)))
subplot(2,1,2), box on
difff = (rollingSharpes(:,4)-rollingSharpes(:,2));
lower = difff.*(difff<=0); lower(isnan(lower)) = 0;
upper = difff.*(difff>0); upper(isnan(upper)) = 0;
jbfill(datenum(dates)',zeros(numel(dates),1)',lower','r');
jbfill(datenum(dates)', upper', zeros(numel(dates),1)', 'g');
xlim([datenum(dates(1)), datenum(dates(end))])
ylim([-1.75,1.75])
dynamicDateTicks()
ylabel('Rolling Sharp difference')
title(sprintf('%s vs %s, Rolling %d-year Sharpe. Integral: %.1f',models{4}, models{2}, years, NansumNan(difff)))



%% Plot with RP = BIN(TF)

models = fieldnames(outCome.Models);
rollingSharpes = []; years = 1; 
rollingMeans = [];
rollingSTDs = [];

for iModel = 1:numel(models)
  [rollS, rollMu, rollStd] = rollSharpe(outCome.Models.(models{iModel}).rev, years);
  rollingSharpes = [rollingSharpes, rollS(:)];
  rollingMeans = [rollingMeans, rollMu];
  rollingSTDs = [rollingSTDs, rollStd];
end


figure(1), clf, hold on
subplot(2,1,1), box on
difff = (rollingSharpes(:,3)-rollingSharpes(:,1));
lower = difff.*(difff<=0); lower(isnan(lower)) = 0;
upper = difff.*(difff>0); upper(isnan(upper)) = 0;
jbfill(datenum(dates)',zeros(numel(dates),1)',lower','r');
jbfill(datenum(dates)', upper', zeros(numel(dates),1)', 'g');
xlim([datenum(dates(1)), datenum(dates(end))])
ylim([-1.75,1.75])
dynamicDateTicks()
ylabel('Rolling Sharp difference')
title(sprintf('Binary-TF vs TF, Rolling %d-year Sharpe. Integral: %.1f', years, NansumNan(difff)))
subplot(2,1,2), box on
difff = (rollingSharpes(:,4)-rollingSharpes(:,2));
lower = difff.*(difff<=0); lower(isnan(lower)) = 0;
upper = difff.*(difff>0); upper(isnan(upper)) = 0;
jbfill(datenum(dates)',zeros(numel(dates),1)',lower','r');
jbfill(datenum(dates)', upper', zeros(numel(dates),1)', 'g');
xlim([datenum(dates(1)), datenum(dates(end))])
ylim([-1.75,1.75])
dynamicDateTicks()
ylabel('Rolling Sharp difference')
title(sprintf('%s vs %s, Rolling %d-year Sharpe. Integral: %.1f',models{4}, models{2}, years, NansumNan(difff)))

%% Plot rolling mean RPmod MV + Sharpe Rpmod MV

models = fieldnames(outCome.Models);
rollingSharpes = []; years = 1; 
rollingMeans = [];
rollingSTDs = [];

for iModel = 1:numel(models)
  [rollS, rollMu, rollStd] = rollSharpe(outCome.Models.(models{iModel}).rev, years);
  rollingSharpes = [rollingSharpes, rollS(:)];
  rollingMeans = [rollingMeans, rollMu];
  rollingSTDs = [rollingSTDs, rollStd];
end


figure(1), clf, hold on
subplot(2,1,1), box on
difff = (rollingMeans(:,4)-rollingMeans(:,2));
lower = difff.*(difff<=0); lower(isnan(lower)) = 0;
upper = difff.*(difff>0); upper(isnan(upper)) = 0;
jbfill(datenum(dates)',zeros(numel(dates),1)',lower','r');
jbfill(datenum(dates)', upper', zeros(numel(dates),1)', 'g');
xlim([datenum(dates(1)), datenum(dates(end))])
ylim([-1.25,1.25])
dynamicDateTicks()
ylabel('Rolling Mean difference')
title(sprintf('%s vs %s, Rolling %d-year Mean. Integral: %.1f',models{4}, models{2}, years, NansumNan(difff)))
subplot(2,1,2), box on
difff = (rollingSharpes(:,4)-rollingSharpes(:,2));
lower = difff.*(difff<=0); lower(isnan(lower)) = 0;
upper = difff.*(difff>0); upper(isnan(upper)) = 0;
jbfill(datenum(dates)',zeros(numel(dates),1)',lower','r');
jbfill(datenum(dates)', upper', zeros(numel(dates),1)', 'g');
xlim([datenum(dates(1)), datenum(dates(end))])
ylim([-1.75,1.75])
dynamicDateTicks()
ylabel('Rolling Sharp difference')
title(sprintf('%s vs %s, Rolling %d-year Sharpe. Integral: %.1f',models{4}, models{2}, years, NansumNan(difff)))



%% Plot Rolling Std ration and Rolling Mean RPmod vs MV

models = fieldnames(outCome.Models);
rollingSharpes = []; years = 1; 
rollingMeans = [];
rollingSTDs = [];

for iModel = 1:numel(models)
  [rollS, rollMu, rollStd] = rollSharpe(outCome.Models.(models{iModel}).rev, years);
  rollingSharpes = [rollingSharpes, rollS(:)];
  rollingMeans = [rollingMeans, rollMu];
  rollingSTDs = [rollingSTDs, rollStd];
end


figure(1), clf, hold on
subplot(2,1,1), box on
difff = (rollingMeans(:,4)-rollingMeans(:,2));
lower = difff.*(difff<=0); lower(isnan(lower)) = 0;
upper = difff.*(difff>0); upper(isnan(upper)) = 0;
jbfill(datenum(dates)',zeros(numel(dates),1)',lower','r');
jbfill(datenum(dates)', upper', zeros(numel(dates),1)', 'g');
xlim([datenum(dates(1)), datenum(dates(end))])
ylim([-1.25,1.25])
dynamicDateTicks()
ylabel('Rolling Mean difference')
title(sprintf('%s vs %s, Rolling %d-year Mean. Integral: %.1f',models{4}, models{2}, years, NansumNan(difff)))
subplot(2,1,2), box on
difff = (rollingSTDs(:,4)./rollingSTDs(:,2));
lower = difff.*(difff<=1); lower(isnan(lower)) = 1; lower(lower==0) = 1;
upper = difff.*(difff>1); upper(isnan(upper)) = 1; upper(upper==0) = 1;
jbfill(datenum(dates)',ones(numel(dates),1)',lower','r');
jbfill(datenum(dates)', upper', ones(numel(dates),1)', 'g');
xlim([datenum(dates(1)), datenum(dates(end))])
ylim([0.85,1.1])
dynamicDateTicks()
ylabel('Rolling Std ratio')
title(sprintf('%s vs %s, Rolling %d-year Std ratio. Integral: %.1f',models{4}, models{2}, years, NansumNan(difff - 1)))




%%

parts = {'Mean return', 'Std'}; rollingParts = {rollingMeans, rollingSTDs};
for i = 1:2
figure(i+1)
rollingSharpes = rollingParts{i}; 

subplot(2,1,1)
difff = (rollingSharpes(:,4)-rollingSharpes(:,2));
lower = difff.*(difff<=0); lower(isnan(lower)) = 0;
upper = difff.*(difff>0); upper(isnan(upper)) = 0;
jbfill(datenum(dates)',zeros(numel(dates),1)',lower','r');
jbfill(datenum(dates)', upper', zeros(numel(dates),1)', 'g');
xlim([datenum(dates(1)), datenum(dates(end))])
dynamicDateTicks()
ylabel(sprintf('Rolling %s difference', parts{i}))
title(sprintf('%s vs %s, Rolling %d-year %s. Integral: %.1f',models{4}, models{2}, years, parts{i}, NansumNan(difff)))
ylim([-(i+1), i+1])

subplot(2,1,2)
difff = (rollingSharpes(:,3)-rollingSharpes(:,1));
lower = difff.*(difff<=0); lower(isnan(lower)) = 0;
upper = difff.*(difff>0); upper(isnan(upper)) = 0;
jbfill(datenum(dates)',zeros(numel(dates),1)',lower','r');
jbfill(datenum(dates)', upper', zeros(numel(dates),1)', 'g');
xlim([datenum(dates(1)), datenum(dates(end))])
dynamicDateTicks()
ylabel(sprintf('Rolling %s difference', parts{i}))
title(sprintf('%s vs %s, Rolling %d-year %s. Integral: %.1f',models{3}, models{1}, years, parts{i}, NansumNan(difff)))
ylim([-(i+1), i+1])

end
