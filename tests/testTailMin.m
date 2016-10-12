
M = ~isnan(outCome.General.dZ(7000,:));
X = outCome.General.dZ(7000:end,M);

[T,N] = size(X);
% U = nan(T,N);
F = zeros(T,N);
for iN = 1:N
  F(:,iN) = ksdensity(X(:,iN),X(:,iN),'function','cdf');
end
[Rho,nu] = copulafit('t',F,'Method','ApproximateML');
Y_u = copularnd('t', Rho, nu, 5000);

Y = zeros(size(Y_u));
for iN = 1:N
  iN
  Y(:,iN) = ksdensity(X(:,iN),Y_u(:,iN),'function','icdf');
end

Y2 = Y.*(abs(Y_u-0.5)>=0.5-0.1); %quantiles



%%

[testPos, times, assets, lookBack] = probMat(outCome, Config ,Y2, M);


%%
[sharpe, equityCurve, htime, rev] = indivitualResults(testPos, Config.cost, Open(times,assets), Close(times,assets), outCome.General.std(times,assets), Config.riskAdjust);
TFpos = outCome.Models.TF.pos(times,assets); TFpos(1:lookBack,:) = NaN;
[sharpeTF, equityCurveTF, htimeTF, revTF] = indivitualResults(TFpos, Config.cost, Open(times,assets), Close(times,assets), outCome.General.std(times,assets), Config.riskAdjust);


figure(1), clf, hold on
plot(dates(times), equityCurveTF)
plot(dates(times),equityCurve)

sRev = sort(diff(equityCurve(~isnan(equityCurve)))); sRevTF = sort(diff(equityCurveTF(~isnan(equityCurveTF))));
%take = length(times);
%meanQuatile = [mean(sRev(1:take)), mean(sRevTF(1:take))]
figure(2), clf, hold on
bar(sRev,'r')
bar(sRevTF)




drawdown = equityCurve-cummax(equityCurve);
drawdownTF = equityCurveTF-cummax(equityCurveTF);
figure(3), clf, hold on
plot(dates(times), drawdownTF)
plot(dates(times), drawdown)





