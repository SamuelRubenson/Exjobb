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

