
M = ~isnan(outCome.General.dZ(7000,:));
X = outCome.General.dZ(7000:8000,M);

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
Y2 = Y.*(abs(Y_u-0.5)>=0.5-0.05); %quantiles



%%

[testPos, times, assets, lookBack] = probMat(outCome, Config ,Y, M);


%%
[sharpe, equityCurve, htime, rev] = indivitualResults(testPos, Config.cost, Open(times,assets), Close(times,assets), outCome.General.std(times,assets), Config.riskAdjust);
TFpos = outCome.Models.TF.pos(times,assets); TFpos(1:lookBack,:) = NaN;
[sharpeTF, equityCurveTF, htimeTF, revTF] = indivitualResults(TFpos, Config.cost, Open(times,assets), Close(times,assets), outCome.General.std(times,assets), Config.riskAdjust);


figure(1), clf, hold on
plot(dates(times), equityCurveTF)
plot(dates(times),equityCurve)

sRev = sort(diff(equityCurve(~isnan(equityCurve)))); sRevTF = sort(diff(equityCurveTF(~isnan(equityCurveTF))));
take = 25;
meanQuatile = [mean(sRev(1:take)), mean(sRevTF(1:take))]



