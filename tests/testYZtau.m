load 160830

taus = 2:2:60;
sh = zeros(numel(taus), 2);
p_tf = zeros(numel(taus), 2);
p_mv = zeros(numel(taus), 2);

mean_var = zeros(numel(taus), 74);
for itau = 1:numel(taus)
  tau = taus(itau)
  yzv=yangzhang(cat(3,Open,High,Low,Close), tau);
  yz = sqrt(yzv([1 1:end-1],:));
  dZ = [nan(1,74) ; diff(lvcf(Close))]./yz;
  mean_var(itau,:) = nanmean(dZ.^2);
  corrMat_t = estCorrMat(dZ, Config.cov_tau, Config.cov_filter);
  Q = cat(3, corrMat_t(:,:,1), corrMat_t(:,:,1:end-1));
  
  tf_pos = getTFpos(dZ, Q, 200, 10, 1);
  [sharpe,~, ht, sh_p] = indivitualResults(tf_pos, 0, Open, Close, yz);
  sh(itau, 1) = sharpe;
  p_tf(itau,:) = sh_p;
  
  mv_pos = getMVpos(tf_pos, Q, 1, 0.7);
  [sharpe,~, ~, sh_p] = indivitualResults(mv_pos, 0, Open, Close, yz);
  sh(itau, 2) = sharpe;
  p_mv(itau,:) = sh_p;
end
%%

figure(1), clf, hold on, title('Sharpe'), xlabel('YZ-tau')
plot(taus, sh)

figure(2), clf, hold on,
yyaxis left
plot(taus, p_mv(:,1))
yyaxis right
plot(taus, p_mv(:,2))
legend('\mu', '\sigma')
%plot(taus, p_mv(:,1)./p_mv(:,2)*sqrt(252))