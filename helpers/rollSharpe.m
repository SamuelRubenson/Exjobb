function [ sh ] = rollSharpe(rev, nYears)

T = numel(rev);
tau = 252*nYears;
sh = nan(T,1);
start = find(~isnan(rev),1,'first');

for t = tau+start:T
  sh(t) = nanmean(rev(t-tau:t-1))/nanstd(rev(t-tau:t-1));
end
sh = sh*sqrt(252);

end

