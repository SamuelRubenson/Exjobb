models = fieldnames(outCome.Models);
tmp = nanmean(cat(2, outCome.Models.TF.equityCurve) - cummax(cat(2,outCome.Models.TF.equityCurve),1));
for i=1:length(outCome.Models.TF) 
  outCome.Models.TF(i).meanDraw = tmp(i);
  outCome.Models.TF(i).meanDraw2 = tmp(i);
  outCome.Models.TF(i).sharpe2 = outCome.Models.TF(i).sharpe;
  %outCome.Models.LES(i).storeSharpe = outCome.Models.LES(i).sharpe;
  %outCome.Models.LES(i).sharpe = outCome.Models.LES(i).sharpe2;
end
key = 'meanDraw';
tau = cat(2,outCome.Models.TF.tau);
figure(1)
subplot(2,2,1), hold on
for i = 1:numel(models)
  vals = (cat(2, outCome.Models.(models{i}).sharpe));
  plot(tau,vals)
end
title('Sharpe'), xlabel('\tau'), box on
subplot(2,2,2), hold on
for i = 1:numel(models)
  vals = (cat(2, outCome.Models.(models{i}).meanDraw));
  plot(tau,vals)
end
legend(models(1:end)), title('Average Drawdown'), xlabel('\tau'), ylabel('Annualized \sigma'), box on


subplot(2,2,3), hold on
for i = 1:numel(models)
plot(tau(2:end), squeeze(NansumNan(NansumNan(abs(diff(cat(3,outCome.Models.(models{i}).pos),1,3)))/(74*9485))))
end
legend(models(1:end)), title('Average Absolute position difference between jumps in \tau'), xlabel('\tau'), ylabel('\delta w'), box on

subplot(2,2,4), hold on
nTau = numel(outCome.Models.TF);
TFcorrs = [];
for it = 1:nTau
  tmp = [];
  for im = 1:numel(models)
    tmp = [tmp, diff(outCome.Models.(models{im})(it).equityCurve(:),1)];
  end
  %figure(), plot(tmp)
  c = corr(tmp, 'rows', 'complete');
  TFcorrs = [TFcorrs; c(1,:)];
end
plot(tau, TFcorrs)
title('Equitycurve-Correlation with trend follower'), xlabel('\tau'), ylabel('\rho'), box on
%%

figure(1), clf
subplot(1,2,1), hold on
vals = (cat(2, outCome.Models.TF.sharpe));
plot(tau,vals)
vals = (cat(2, outCome.Models.LES.sharpe));
plot(tau,vals)
subplot(1,2,2)
plot(tau, TFcorrs(:,end))

%% Check before / after correlation
models = fieldnames(outCome.Models);
X = [1:6];
store = [];
for i = 1:numel(models)
test = cat(2,outCome.Models.(models{i}).equityCurve);
test = diff(test,1);
test2 = test(:, X);
c = corr(test2,'rows','complete');
store = [store; mean( mean( c(~eye(size(test2,2))) ) )];
end
figure(), bar(store)








%% With several reg

colors =[0.8500,    0.3250,    0.0980;
         0.9290,    0.6940,    0.1250;
         0.4940,    0.1840,    0.5560;
         0.4660,    0.6740,    0.1880;];

models = fieldnames(outCome.Models);

figure(1), clf, hold on,
%figure(2), clf, hold on,

tau = cat(2,outCome.Models.TF.tau);
lambda = outCome.Models.MV(1).lambda(1:end);
TF_sharpe = cat(2, outCome.Models.TF.sharpe);

for iM = [1:4]
  sh = cat(2,outCome.Models.(models{iM}).sharpe);
  md = cat(2,outCome.Models.(models{iM}).meanDraw);
  [m, i] =  max(sh,[],1); n = size(sh,2);
  ind = sub2ind(size(sh), i', (1:n)');
  figure(1), plot(tau, sh(ind))
  title('Sharpe'), xlabel('TF \tau')
  figure(2), hold on, plot(tau, max(md, [], 1))
  xlabel('TF \tau'), ylabel('Annualized Std'), title('Average Drawdown')
  %h = surf(tau, lambda, sh(1:end,:));
  %set(h, 'FaceColor', colors(iM-1,:), 'FaceAlpha', 0.8);
end
%sh = cat(1,outCome.Models.LES.sharpe)';
%md = cat(1,outCome.Models.LES.meanDraw)';
%[m, i] =  max(sh,[],1); n = size(sh,2);
%ind = sub2ind(size(sh), i', (1:n)');
%figure(1), plot(tau, sh(ind))
%figure(2), plot(tau, max(md))

%h = surf(tau, lambda, sh(1:end-1,:));
%set(h, 'FaceColor', colors(4,:), 'FaceAlpha', 1);
figure(1), legend(models([1:4]))
figure(2), legend(models([1:4]))
%%

figure(1), clf, hold on,
%figure(2), clf, hold on,

tau = cat(2,outCome.Models.TF.tau);
lambda = outCome.Models.MV(1).lambda(1:end);
TF_sharpe = cat(2, outCome.Models.TF.sharpe);

for iM = [2:4]
  sh = cat(2,outCome.Models.(models{iM}).sharpe);
  md = cat(2,outCome.Models.(models{iM}).meanDraw);
  %[m, i] =  max(sh,[],1); n = size(sh,2);
  %ind = sub2ind(size(sh), i', (1:n)');
  subplot(1,2,1), hold on, h=surf(tau, lambda, sh); set(h, 'FaceColor', colors(iM-1,:), 'FaceAlpha', 1);
  xlim([45, 315]), xlabel('TF \tau'), ylabel('\lambda'), title('Sharpe')
  subplot(1,2,2), hold on, h=surf(tau, lambda, md); set(h, 'FaceColor', colors(iM-1,:), 'FaceAlpha', 1);
  xlim([45, 315]), xlabel('TF \tau'), ylabel('\lambda'), zlabel('Annualized Std'), title('Average Drawdown')
  %h = surf(tau, lambda, sh(1:end,:));
  %set(h, 'FaceColor', colors(iM-1,:), 'FaceAlpha', 0.8);
end
%sh = cat(1,outCome.Models.LES.sharpe)';
%h = surf(tau, lambda, sh(1:end-1,:));
%set(h, 'FaceColor', colors(4,:), 'FaceAlpha', 1);
legend(models([2:4]))




%% Check before / after correlation
models = fieldnames(outCome.Models);
X = [1:3:14]; mInd = [7, 6, 4, 9];
all = [];
for il = 1:10
store = [];
tf_eq = cat(2,outCome.Models.TF.equityCurve); 
test = diff(tf_eq,1);
test2 = test(:, X);
c = corr(test2,'rows','complete');
store = [store; mean( mean( c(~eye(size(test2,2))) ) )];
for i = 2:numel(models)
test = cat(3,outCome.Models.(models{i}).equityCurve);
test = diff(test,1);
test2 = test(:, :, X);
c = corr(squeeze(test2(:,il,:)),'rows','complete');
store = [store; mean( mean( c(~eye(size(test2,3))) ) )];
end
all = [all, store];
end

figure(), plot(0.1:0.1:1', all)


%% Check with costs.


models = fieldnames(outCome.Models);

store = [];
cost = 0.01:0.01:0.15;
for c = cost
c
stuff = struct;
for im = 1:numel(models)
  pos = cat(4, outCome.Models.(models{im}).pos);
  sharpe = zeros(size(pos,4), size(pos,3)); meanDraw = zeros(size(pos,4), size(pos,3)); 
  for itau = 1:size(pos,4)
    for il = 1:size(pos,3)
    
      ipos = pos(:,:,il, itau);
      [sh, eq, ht] = indivitualResults(ipos, c, Open, Close, outCome.General.std, false);
      MD = nanmean(eq - cummax(eq));
      meanDraw(itau, il) = MD; sharpe(itau, il) = sh;
    
    end
  end
  stuff.(models{im}) = struct('sharpe', max(sharpe, [], 2), 'meanDraw', max(meanDraw, [], 2));
end
store = [store; stuff];
end


%storeSharpe = [storeSharpe,  max(stuff.(models{im}).sharpe, [],  2)];
%storeMD = [storeMD,  max(stuff.(models{im}).sharpe, [],  2)];
%end

%%
c =[      0,    0.4470,    0.7410;
         0.8500,    0.3250,    0.0980;
         0.9290,    0.6940,    0.1250;
         0.4940,    0.1840,    0.5560;];
figure(2), clf, hold on
tf = [store.TF];
%tf = surf(cat(2,outCome.Models.TF.tau), cost, cat(2,tmp.sharpe)');
for im = 2:numel(models)
  tmp = [store.(models{im})];
  
  %plot(cat(2,outCome.Models.TF.tau), max(stuff.(models{im}).sharpe, [],  2));
  h = surf(cat(2,outCome.Models.TF.tau), cost, cat(2,tmp.sharpe)' - cat(2,tf.sharpe)');
  set(h, 'FaceColor', c(im,:), 'FaceAlpha', 1)
end
b = surf(cat(2,outCome.Models.TF.tau), cost, zeros(size(cat(2,tmp.sharpe)')));
set(b, 'FaceColor', [0 0 0], 'FaceAlpha', 0.5)
xlim([45, 300])
xlabel('TF \tau'), ylabel('Cost per \sigma')
title('Marginal Sharpe')

figure(3), clf, hold on
tf = [store.TF];
%tf = surf(cat(2,outCome.Models.TF.tau), cost, cat(2,tmp.sharpe)');
for im = 1:numel(models)
  tmp = [store.(models{im})];
  
  %plot(cat(2,outCome.Models.TF.tau), max(stuff.(models{im}).sharpe, [],  2));
  h = surf(cat(2,outCome.Models.TF.tau), cost, cat(2,tmp.meanDraw)');
  set(h, 'FaceColor', c(im,:), 'FaceAlpha', 1)
end
%b = surf(cat(2,outCome.Models.TF.tau), cost, zeros(size(cat(2,tmp.sharpe)')));
%set(b, 'FaceColor', [0 0 0], 'FaceAlpha', 0.5)
xlim([45, 300])
xlabel('TF \tau'), ylabel('Cost per \sigma'), zlabel('Annualized standard deviations')
title('Average Drawdown')
