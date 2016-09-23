function [ sharpe ] = sharpeOfCost(outCome, model, costs, Open, Close)
  nCosts = numel(costs);
  nReg = numel(outCome.Models.(model).sharpe);
  sharpe = zeros(nCosts, nReg);
  for iReg = 1:nReg
    for iCost = 1:length(costs)
      cost = costs(iCost);
      sharpe(iCost, iReg) = indivitualResults(outCome.Models.(model).pos(:,:,iReg),cost, Open, Close, outCome.General.std);
    end
  end
end