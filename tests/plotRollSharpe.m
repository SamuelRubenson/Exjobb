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
subplot(2,1,1)
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
subplot(2,1,2)
difff = (rollingSharpes(:,3)-rollingSharpes(:,1));
lower = difff.*(difff<=0); lower(isnan(lower)) = 0;
upper = difff.*(difff>0); upper(isnan(upper)) = 0;
jbfill(datenum(dates)',zeros(numel(dates),1)',lower','r');
jbfill(datenum(dates)', upper', zeros(numel(dates),1)', 'g');
xlim([datenum(dates(1)), datenum(dates(end))])
ylim([-1.75,1.75])
dynamicDateTicks()
ylabel('Rolling Sharp difference')
title(sprintf('%s vs %s, Rolling %d-year Sharpe. Integral: %.1f',models{3}, models{1}, years, NansumNan(difff)))

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
