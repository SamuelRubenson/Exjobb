function [ outCome ] = changeCost(outCome,cost,Open,Close)

models = fieldnames(outCome.Models);

for iModel = 1:length(models);
[sharpe, equityCurve, htime] = indivitualResults(outCome.Models.(models{iModel}).pos,...
  cost, Open, Close, outCome.General.std);
outCome.Models.(models{iModel}).sharpe = sharpe;
outCome.Models.(models{iModel}).equityCurve = equityCurve;
outCome.Models.(models{iModel}).htime = htime;
end


end

