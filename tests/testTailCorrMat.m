dZ = outCome.General.dZ; 
lookBack = 252;
[endT, nMarkets] = size(dZ);
q = 0.025;
alpha = 1 - 1/120;

tailQ = nan(nMarkets, nMarkets, endT);

maxM = 0;

for t = lookBack+1:endT
t
M = ~isnan(outCome.General.dZ(t-lookBack+1,:));
X = outCome.General.dZ(t-lookBack+1:t,M);

[T,N] = size(X);

if N>maxM || mod(t,10)==0
maxM = N;
% U = nan(T,N);
F = zeros(T,N);
for iN = 1:N
  F(:,iN) = ksdensity(X(:,iN),X(:,iN),'function','cdf');
end
[Rho,nu] = copulafit('t',F,'Method','ApproximateML');
Y_u = copularnd('t', Rho, nu, 500);

Y = zeros(size(Y_u));
for iN = 1:N
  Y(:,iN) = ksdensity(X(:,iN),Y_u(:,iN),'function','icdf');
end

pointEst = zeros(N,N);
for i = 1:N
  for j=1:N
    tailInd_i = abs(Y_u(:,i)-0.5)>(0.5-q);
    pointEst(i,j) = mean( Y(tailInd_i, i).*Y(tailInd_i, j) );
  end
end

end

out = nan(nMarkets, nMarkets);
out(M,M) = pointEst;

tailQ(:,:,t) = out;

end

%Y2 = Y.*(abs(Y_u-0.5)>=0.5-0.05); %quantiles

%% rolling est

rolling_est = nan(size(tailQ)); a = 1-1/60;
for it = 2:endT
  Y_t = tailQ(:,:,it);
  C_t = a*rolling_est(:,:,it-1) + (1-a)*Y_t;

  idx_new = isnan(Y_t);
  idx_prev = isnan(rolling_est(:,:,it-1));
  only_new = logical((~idx_new).*idx_prev); 
  C_t(only_new) = (1-a)*Y_t(only_new);

  rolling_est(:,:,it) = C_t;
end


%% normalize

C = rolling_est;
C_norm = nan(size(C));
for it = 2:endT
  variances = repmat(diag(C(:,:,it)),1,N);
  norm_mat = sqrt(variances'.*variances);
  C_norm(:,:,it) = C(:,:,it)./norm_mat;
end

%% TEST

clc
Q = outCome.General.corr;
mv = getMVpos(outCome.Models.TF.pos, C, 10, 0);
[sharpe, equityCurve, htime, rev, sharpeParts] = indivitualResults(mv, Config.cost, Open, Close, outCome.General.std, Config.riskAdjust);
TFpos = outCome.Models.MV.pos; TFpos(isnan(mv)) = NaN;
[sharpeTF, equityCurveTF, htimeTF, revTF, sharpePartsTF] = indivitualResults(TFpos, Config.cost, Open, Close, outCome.General.std, Config.riskAdjust);
[sharpeParts, sharpe]
[sharpePartsTF, sharpeTF]
figure(), hold on, plot(dates, [equityCurveTF, equityCurve])

