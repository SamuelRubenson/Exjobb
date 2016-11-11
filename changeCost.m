function [ outCome ] = changeCost(outCome,cost, riskAdjust, Open,Close)

models = fieldnames(outCome.Models);

for iModel = 1:length(models)
[sharpe, equityCurve, htime, r] = indivitualResults(outCome.Models.(models{iModel}).pos,...
  cost, Open, Close, outCome.General.std, riskAdjust);
outCome.Models.(models{iModel}).sharpe = sharpe;
outCome.Models.(models{iModel}).equityCurve = equityCurve;
outCome.Models.(models{iModel}).htime = htime;
outCome.Models.(models{iModel}).rev = r;
end


end

