function [ sh, storeMean, storeStd ] = rollSharpe(rev, nYears)

T = numel(rev);
tau = 252*nYears;
sh = nan(T,1);
storeMean = nan(T,1);
storeStd = nan(T,1);
start = find(~isnan(rev),1,'first');

for t = tau+start:T
  mu = nanmean(rev(t-tau:t-1));
  std = nanstd(rev(t-tau:t-1));
  sh(t) = mu/std;
  storeMean(t) = mu;
  storeStd(t) = std;
end
sh = sh*sqrt(252);

end

