pos = (outCome.Models.RP.pos + outCome.Models.MV.pos);
Q = outCome.General.corr;

[T,N] = size(pos);

for t = 1:T
  activeI = logical(any(Q(:,:,t)).*(~isnan(pos(t,:))));
  pos(t,activeI) = pos(t,activeI)*Config.target_volatility/sqrt(pos(t,activeI)*Q(activeI,activeI,t)*pos(t,activeI)');
end

[sharpe, equityCurve, htime, ret] = indivitualResults(pos, 0, Open(start:end,X), Close(start:end,X), outCome.General.std, false);

figure(1), hold on, plot(dates(start:end),equityCurve)


%%
models = fields(outCome.Models);
mCvar = [];
for iModel = 1:numel(models)
  mCvar = [mCvar; meanCVaR(outCome.Models.(models{iModel}).rev, 0.85)];
end
figure(), bar(mCvar)