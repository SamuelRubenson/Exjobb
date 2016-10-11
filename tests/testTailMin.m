[testPos, times, assets, lookBack] = probMat(outCome, Config);
%%
[sharpe, equityCurve, htime, rev] = indivitualResults(testPos, Config.cost, Open(times,assets), Close(times,assets), outCome.General.std(times,assets), Config.riskAdjust);
TFpos = outCome.Models.TF.pos(times,assets); TFpos(1:lookBack,:) = NaN;
[sharpeTF, equityCurveTF, htimeTF, revTF] = indivitualResults(TFpos, Config.cost, Open(times,assets), Close(times,assets), outCome.General.std(times,assets), Config.riskAdjust);


figure(1), clf, hold on
plot(dates(times), equityCurveTF)
plot(dates(times),equityCurve)

sRev = sort(diff(equityCurve(~isnan(equityCurve)))); sRevTF = sort(diff(equityCurveTF(~isnan(equityCurveTF))));
take = 4;
meanQuatile = [mean(sRev(1:take)), mean(sRevTF(1:take))]