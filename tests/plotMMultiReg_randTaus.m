colors =[0.8500,    0.3250,    0.0980;
         0.9290,    0.6940,    0.1250;
         0.4940,    0.1840,    0.5560;
         0.4660,    0.6740,    0.1880;];
lambda = 0:0.1:1;
models = {'MV', 'RP', 'RPmod'};

figure(1), clf,
subplot(1,2,1), title('Sharpe'), hold on, xlabel('\lambda')
tf = plot(lambda, mean(out.TF.sharpe)*ones(numel(lambda),1), 'LineWidth', 1.5);
h = tf;
for im = 1:numel(models)
  m_sharpe = out.(models{im}).sharpe;
  ih = plot(lambda, mean(m_sharpe)', 'Color', colors(im,:), 'LineWidth', 1.5);
  h = [h; ih];
  upper = mean(m_sharpe)' + 2*std(m_sharpe)';
  lower =  mean(m_sharpe)' - 2*std(m_sharpe)';
  plot(lambda, upper , '-', 'Color', colors(im,:), 'LineWidth', 0.5)
  plot(lambda, lower, '-', 'Color', colors(im,:), 'LineWidth', 0.5)
  jbfill(lambda, upper', lower', colors(im,:), 'k', 1, .25);
  %plot([0 1], [0 0], 'k')
end
legend(h, [{'TF'}, models])

subplot(1,2,2), title('Marginal Sharpe'), hold on, xlabel('\lambda')
%plot(lambda, mean(out.TF.sharpe)*ones(numel(lambda),1))
h = [];
for im = 1:numel(models)
  m_sharpe = out.(models{im}).sharpe - out.TF.sharpe;
  ih = plot(lambda, mean(m_sharpe)', 'Color', colors(im,:), 'LineWidth', 1.5);
  h = [h; ih];
  upper = mean(m_sharpe)' + 2*std(m_sharpe)';
  lower =  mean(m_sharpe)' - 2*std(m_sharpe)';
  plot(lambda, upper , '-', 'Color', colors(im,:), 'LineWidth', 0.5)
  plot(lambda, lower, '-', 'Color', colors(im,:), 'LineWidth', 0.5)
  jbfill(lambda, upper', lower', colors(im,:), 'k', 1, .25);
  plot([0 1], [0 0], 'k')
end
legend(h, models)

figure(3), clf, title('Average Drawdown'), hold on, xlabel('\lambda'), ylabel('Annualized \sigma')
tf = plot(lambda, mean(out.TF.meanDraw)*ones(numel(lambda),1), 'LineWidth', 1.5);
h = tf;
for im = 1:numel(models)
  md = out.(models{im}).meanDraw;
  ih = plot(lambda, mean(md)', 'Color', colors(im,:), 'LineWidth', 1.5);
  h = [h; ih];
  upper = mean(md)' + 2*std(md)';
  lower =  mean(md)' - 2*std(md)';
  plot(lambda, upper , '-', 'Color', colors(im,:), 'LineWidth', 0.5)
  plot(lambda, lower, '-', 'Color', colors(im,:), 'LineWidth', 0.5)
  jbfill(lambda, upper', lower', colors(im,:), 'k', 1, .25);
  %plot([0 1], [0 0], 'k')
end
legend(h, [{'TF'}, models])


figure(4), clf, title('Marginal Average Drawdown'), hold on, xlabel('\lambda'), ylabel('Annualized \sigma')
%tf = plot(lambda, mean(out.TF.meanDraw)*ones(numel(lambda),1));
h = [];
for im = 1:numel(models)
  md = out.(models{im}).meanDraw - out.TF.meanDraw;
  ih = plot(lambda, mean(md)', 'Color', colors(im,:), 'LineWidth', 1.5);
  h = [h; ih];
  upper = mean(md)' + 2*std(md)';
  lower =  mean(md)' - 2*std(md)';
  plot(lambda, upper , '-', 'Color', colors(im,:), 'LineWidth', 0.5)
  plot(lambda, lower, '-', 'Color', colors(im,:), 'LineWidth', 0.5)
  jbfill(lambda, upper', lower', colors(im,:), 'k', 1, .25);
  plot([0 1], [0 0], 'k')
end
legend(h, models)

figure(5), clf
subplot(1,2,1), title('Holding time'), hold on, xlabel('\lambda')
plot(lambda, mean(out.TF.htime)*ones(numel(lambda),1), 'LineWidth', 1.5)
h = [];
for im = 1:numel(models)
  ht = out.(models{im}).htime;
  ih = plot(lambda, mean(ht)', 'Color', colors(im,:), 'LineWidth', 1.5);
  h = [h; ih];
  upper = mean(ht)' + 2*std(ht)';
  lower =  mean(ht)' - 2*std(ht)';
  plot(lambda, upper , '-', 'Color', colors(im,:))
  plot(lambda, lower, '-', 'Color', colors(im,:))
  jbfill(lambda, upper', lower', colors(im,:), 'k', 1, .25);
end
legend(h, models)


subplot(1,2,2), title('Average daily trade'), hold on, xlabel('\lambda'), ylabel('\sigma')
plot(lambda, mean(out.TF.avgTrade)*ones(numel(lambda),1), 'LineWidth', 1.5)
h = [];
for im = 1:numel(models)
  ht = out.(models{im}).avgTrade;
  ih = plot(lambda, mean(ht)', 'Color', colors(im,:), 'LineWidth', 1.5);
  h = [h; ih];
  upper = mean(ht)' + 2*std(ht)';
  lower =  mean(ht)' - 2*std(ht)';
  plot(lambda, upper , '-', 'Color', colors(im,:))
  plot(lambda, lower, '-', 'Color', colors(im,:))
  jbfill(lambda, upper', lower', colors(im,:), 'k', 1, .25);
end
legend(h, models)



%% distribution over (sharpe)best lambda

[~, mvInd] = max(mean(out.MV.sharpe));
[~, rpInd] = max(mean(out.RP.sharpe));
[~, rpmInd] = max(mean(out.RPmod.sharpe));

figure(4), clf, hold on, title('Distribution of marginal Sharpe for "best" \lambda') 
%plot([1.3, 1.59], [0, 0])
%ksdensity(out.TF.sharpe)
[f,x] = ksdensity(out.MV.sharpe(:,mvInd) - out.TF.sharpe);%, 'width', 0.015)
plot(x,f,'Color',colors(1,:))
[f,x] = ksdensity(out.RP.sharpe(:,rpInd) - out.TF.sharpe);%, 'width', 0.015)
plot(x,f,'Color',colors(2,:))
[f,x] = ksdensity(out.RPmod.sharpe(:,rpmInd) - out.TF.sharpe);%, 'width', 0.01)
plot(x,f,'Color',colors(3,:))
legend(['MV, \lambda = ', num2str(mvInd/10 - 0.1)],...
       ['RP, \lambda = ', num2str(rpInd/10 - 0.1)],...
       ['RPmod, \lambda = ', num2str(rpmInd/10 - 0.1)])
     

% [~, mvInd] = max(mean(out.MV.meanDraw));
% [~, rpInd] = max(mean(out.RP.meanDraw));
% [~, rpmInd] = max(mean(out.RPmod.meanDraw));
figure(5), clf, hold on, title('Distribution of marginal average Drawdown for "best" \lambda')  
%plot([1.3, 1.59], [0, 0])
%ksdensity(out.TF.sharpe)
[f,x] = ksdensity(out.MV.meanDraw(:,mvInd) - out.TF.meanDraw);%, 'width', 0.015)
plot(x,f,'Color',colors(1,:))
[f,x] = ksdensity(out.RP.meanDraw(:,rpInd) - out.TF.meanDraw);%, 'width', 0.015)
plot(x,f,'Color',colors(2,:))
[f,x] = ksdensity(out.RPmod.meanDraw(:,rpmInd) - out.TF.meanDraw);%, 'width', 0.01)
plot(x,f,'Color',colors(3,:))
legend(['MV, \lambda = ', num2str(mvInd/10 - 0.1)],...
       ['RP, \lambda = ', num2str(rpInd/10 - 0.1)],...
       ['RPmod, \lambda = ', num2str(rpmInd/10 - 0.1)])
     

figure(6), clf, hold on 
[f,x] = ksdensity(out.MV.htime(:,mvInd));%, 'width', 0.015)
plot(x,f,'Color',colors(1,:))
[f,x] = ksdensity(out.RP.htime(:,rpInd));%, 'width', 0.015)
plot(x,f,'Color',colors(2,:))
[f,x] = ksdensity(out.RPmod.htime(:,rpmInd));%, 'width', 0.01)
plot(x,f,'Color',colors(3,:))
legend(['MV, \lambda = ', num2str(mvInd/10 - 0.1)],...
       ['RP, \lambda = ', num2str(rpInd/10 - 0.1)],...
       ['RPmod, \lambda = ', num2str(rpmInd/10 - 0.1)])

%% STD 

figure(7), clf, hold on, title('Std of Sharpe'), xlabel('\lambda'), ylabel('\sigma')
plot(lambda, std(out.MV.sharpe - out.TF.sharpe), 'Color', colors(1,:))
plot(lambda, std(out.RP.sharpe - out.TF.sharpe), 'Color', colors(2,:))
plot(lambda, std(out.RPmod.sharpe - out.TF.sharpe), 'Color', colors(3,:))

     
%% MV vs RPmod
sharpe_diff = out.RPmod.sharpe - out.MV.sharpe; 
figure(8),
hist(sharpe_diff(:),50)

%% Dependence M-Sharpe on YZ

[~, mvInd] = max(mean(out.MV.sharpe));
[~, rpInd] = max(mean(out.RP.sharpe));
[~, rpmInd] = max(mean(out.RPmod.sharpe));

figure(9), clf
subplot(1,2,1), title('MV'), hold on
scatter(out.yz, out.MV.sharpe(:,mvInd)-out.TF.sharpe, 100, '.')
xlabel('Yang Zhang \tau'), ylabel('Marginal Sharpe')
subplot(1,2,2), title('RPmod'), hold on
scatter(out.yz, out.RPmod.sharpe(:,rpmInd)-out.TF.sharpe, 100, '.')
xlabel('Yang Zhang \tau'), ylabel('Marginal Sharpe')


figure(10), clf
subplot(1,2,1), title('MV'), hold on
scatter(out.cov_tau, out.MV.sharpe(:,mvInd)-out.TF.sharpe, 100, '.')
xlabel('Correlation \tau'), ylabel('Marginal Sharpe')
subplot(1,2,2), title('RPmod'), hold on
scatter(out.cov_tau, out.RPmod.sharpe(:,rpmInd)-out.TF.sharpe, 100, '.')
xlabel('Correlation \tau'), ylabel('Marginal Sharpe')

%%  When is RPmod better than MV?
[~, mvInd] = max(mean(out.MV.sharpe));
[~, rpInd] = max(mean(out.RP.sharpe));
[~, rpmInd] = max(mean(out.RPmod.sharpe));

binTFdiff = out.RP.sharpe(:,end) - out.TF.sharpe; 
rpm_mv_diff = out.RPmod.sharpe(:,rpmInd) - out.MV.sharpe(:,mvInd);



figure(11), clf, hold on, title('When is RPmod better than MV?')
scatter(binTFdiff, rpm_mv_diff, 100, out.yz, '.')
xlabel('Sharpe difference BinaryTF / TF'), ylabel('Sharpe difference RPmod / MV')
legend(['Correlation \rho = ', num2str(corr(binTFdiff, rpm_mv_diff))])
