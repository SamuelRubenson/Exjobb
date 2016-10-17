
N = size(Y,2);
P = zeros(N);
P2 = zeros(N);

for i = 1:N
  for j = 1:N
    firstD = Y2(:,i)<0;
    secondD = Y2(:,j)<0;

    pi_D = sum(Y2(secondD,i)<0)/sum(secondD);
    pj_D = sum(Y2(firstD,j)<0)/sum(firstD);
    P(i,j) = (pi_D+pj_D)/2;
  end
end


for i = 1:N
  for j = 1:N
    firstD = Y2(:,i)<0;
    secondU = Y2(:,j)>0;

    pi_D = sum(Y2(secondU,i)<0)/sum(secondU);
    pj_U = sum(Y2(firstD,j)>0)/sum(firstD);
    P2(i,j) = (pi_D+pj_U)/2;
  end
end
P2 = (P2+P2')/2;


%%

figure()
subplot(1,2,1)
imagesc(P)
subplot(1,2,2)
imagesc(P2)

PP = P-P2;

figure(), surf(PP)
%%
clc
Q = outCome.General.corr;
mv = getMVpos(outCome.Models.TF.pos, 0.5*Q + 0.5*C_norm, 10, 0.5);
[sharpe, equityCurve, htime, rev, sharpeParts] = indivitualResults(mv, Config.cost, Open, Close, outCome.General.std, Config.riskAdjust);
TFpos = outCome.Models.MV.pos; TFpos(isnan(mv)) = NaN;
[sharpeTF, equityCurveTF, htimeTF, revTF, sharpePartsTF] = indivitualResults(TFpos, Config.cost, Open, Close, outCome.General.std, Config.riskAdjust);
sharpeParts
sharpePartsTF
figure(), hold on, plot(dates, [equityCurveTF, equityCurve])



