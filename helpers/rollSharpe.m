function [ sh, parts ] = rollSharpe(rev, nYears)

T = numel(rev);
tau = 252*nYears;
sh = nan(T,1);
parts = nan(T,2);
start = find(~isnan(rev),1,'first');

for t = tau+start:T
  mu = nanmean(rev(t-tau:t-1));
  std = nanstd(rev(t-tau:t-1));
  sh(t) = mu/std;
  parts(t,:) = [mu, std];
end
sh = sh*sqrt(252);

end

