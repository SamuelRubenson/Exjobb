c =[      0,    0.4470,    0.7410;
         0.8500,    0.3250,    0.0980;
         0.9290,    0.6940,    0.1250;
         0.4940,    0.1840,    0.5560;];

ind = 1:4;
figure(1), clf, hold on
for i = ind
mat = squeeze(sharpe(:,:,i));
ih = surf(lookBack, alpha, mat);
set(ih, 'Facecolor', c(i,:), 'Facealpha', 1 )
end

figure(2), clf, hold on
for i = ind
mat = squeeze(meanDraw(:,:,i));
ih = surf(lookBack, alpha, mat);
set(ih, 'Facecolor', c(i,:), 'Facealpha', 1 )
end

%%
% h = surf(alpha, lambda, outCome.Models.TF.sharpe*ones(size(mat)));
% set(h, 'Facecolor', [0,0.4470,0.7410], 'Facealpha', 0.5 )
% h2 = surf(alpha, lambda, outCome.Models.MV.sharpe*ones(size(mat)));
% set(h2, 'Facecolor', c(2,:), 'Facealpha', 0.5 )

%% LES 1 alpha PLOT IN REPORT

figure(20), clf
i=4;
subplot(2,2,1), hold on, title(sprintf('Sharpe for lambda=%.1f',lambda(i)))
TF = surf(alpha, lookBack, 1.31*ones(size(sharpe(:,:,1)')));
set(TF, 'Facecolor', [0,0.4470,0.7410], 'Facealpha', 0.5 )
surf(alpha, lookBack, squeeze(sharpe(:,:,i))')
xlabel('\alpha')
ylabel('q')
subplot(2,2,2), hold on, title(sprintf('Average Drawdown for lambda=%.1f',lambda(i)))
TF = surf(alpha, lookBack, -0.385*ones(size(sharpe(:,:,1)')));
set(TF, 'Facecolor', [0,0.4470,0.7410], 'Facealpha', 0.5 )
surf(alpha, lookBack, squeeze(meanDraw(:,:,i))')
xlabel('\alpha')
ylabel('q')
i=1;
subplot(2,2,3), hold on, title(sprintf('Sharpe for lambda=%.1f',lambda(i)))
TF = surf(alpha, lookBack, 1.31*ones(size(sharpe(:,:,1)')));
set(TF, 'Facecolor', [0,0.4470,0.7410], 'Facealpha', 0.5 )
surf(alpha, lookBack, squeeze(sharpe(:,:,i))')
xlabel('\alpha')
ylabel('q')
subplot(2,2,4), hold on, title(sprintf('Average Drawdown for lambda=%.1f',lambda(i)))
TF = surf(alpha, lookBack, -0.385*ones(size(sharpe(:,:,1)')));
set(TF, 'Facecolor', [0,0.4470,0.7410], 'Facealpha', 0.5 )
surf(alpha, lookBack, squeeze(meanDraw(:,:,i))')
xlabel('\alpha')
ylabel('q')


%% LES several alpha in report

toComp = {'TF', 'MV', 'RP', 'RPmod'};
N = numel(toComp);

figure(20), clf, hold on, title('Sharpe')
h = [];
for i = 1:N
ih = surf(LES.lookBack, LES.lambda, outCome.Models.(toComp{i}).sharpe*ones(size(LES.sharpe')));
set(ih, 'Facecolor', c(i,:), 'Facealpha', 0.5 )
h = [h;ih];
end
l = surf(LES.lookBack, LES.lambda, LES.sharpe');
colormap summer
xlabel('q'), ylabel('\lambda'), zlabel('Annualized Sharpe ratio')
legend([l;h], [{'LES'}, toComp])


figure(21), clf, hold on, title('Average drawdown')
h = [];
for i = 1:N
mDraw = nanmean(outCome.Models.(toComp{i}).equityCurve - cummax(outCome.Models.(toComp{i}).equityCurve));
ih = surf(LES.lookBack, LES.lambda, mDraw*ones(size(LES.meanDraw')));
set(ih, 'Facecolor', c(i,:), 'Facealpha', 0.5 )
h = [h;ih];
end
l = surf(LES.lookBack, LES.lambda, LES.meanDraw');
colormap summer
xlabel('q'), ylabel('\lambda'), zlabel('Annualized standard deviations')
legend([l;h], [{'LES'}, toComp])

figure(22), clf, hold on, title('Holding time')
h = [];
for i = 2:N
ih = surf(LES.lookBack, LES.lambda, outCome.Models.(toComp{i}).htime*ones(size(LES.htime')));
set(ih, 'Facecolor', c(i,:), 'Facealpha', 0.5 )
h = [h;ih];
end
l = surf(LES.lookBack, LES.lambda, LES.htime');
colormap summer
xlabel('q'), ylabel('\lambda')
legend([l;h], [{'LES'}, toComp(2:end)])

















