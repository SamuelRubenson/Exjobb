clc
M = ~isnan(outCome.General.dZ(3000,:));
X = outCome.General.dZ(3000:end,M);

[T,N] = size(X);
% U = nan(T,N);
F = zeros(T,N);
for iN = 1:N
  F(:,iN) = ksdensity(X(:,iN),X(:,iN),'function','cdf');
end
[Rho,nu] = copulafit('t',F,'Method','ApproximateML');
Y_u = copularnd('t', Rho, nu, 10000);

Y = zeros(size(Y_u));
for iN = 1:N
  iN
  Y(:,iN) = ksdensity(X(:,iN),Y_u(:,iN),'function','icdf');
end

%%

Y2 = Y.*(abs(Y_u-0.5)>=0.5-0.01); %quantiles


%%

[testPos, times, assets, lookBack] = probMat(outCome, Config, Y2, M);


%%
[sharpe, equityCurve, htime, rev, sharpeParts] = indivitualResults(testPos, Config.cost, Open(times,assets), Close(times,assets), outCome.General.std(times,assets), Config.riskAdjust);
TFpos = outCome.Models.TF.pos(times,assets); TFpos(1:lookBack,:) = NaN;
[sharpeTF, equityCurveTF, htimeTF, revTF, sharpePartsTF] = indivitualResults(TFpos, Config.cost, Open(times,assets), Close(times,assets), outCome.General.std(times,assets), Config.riskAdjust);


figure(1), clf, hold on
plot(dates(times), equityCurveTF)
plot(dates(times),equityCurve)

sRev = sort(diff(equityCurve(~isnan(equityCurve)))); sRevTF = sort(diff(equityCurveTF(~isnan(equityCurveTF))));
take = floor(length(times)/10);
meanQuatile = [mean(sRev(1:take)), mean(sRevTF(1:take))]
figure(2), clf
subplot(1,2,1), hold on
bar(sRevTF(1:take))
bar(sRev(1:take),'r')
subplot(1,2,2), hold on
bar(sRevTF(end-take+1:end))
bar(sRev(end-take+1:end),'r')




drawdown = equityCurve-cummax(equityCurve);
drawdownTF = equityCurveTF-cummax(equityCurveTF);
figure(3), clf, hold on
plot(dates(times), drawdownTF)
plot(dates(times), drawdown)





