function [ sh ] = rollSharpe(rev, nYears)

T = numel(rev);
tau = 252*nYears;
sh = nan(T,1);

for t = tau+1:T
  sh(t) = nanmean(rev(t-tau:t-1))/nanstd(rev(t-tau:t-1));
end
sh = sh*sqrt(252);

end

