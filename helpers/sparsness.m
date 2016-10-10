function [ out ] = sparsness( pos, factor )

[T,N] = size(pos);
store = nan(T,1);
for t = 1:T
  ind = ~isnan(pos(t,:));
  n = sum(ind);
  totSTDst = sum(abs(pos(t,ind)))/n;
  store(t) = sum(abs(pos(t,ind))<(totSTDst/factor))/n;
end
out = nanmean(store);

end

