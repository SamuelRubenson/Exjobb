function [ TFpos ] = getTFpos(dZ, corrMat, aLong, aShort, target_volatility)

if isempty(aLong), aLong = 200; end
if isempty(aShort), aShort = 10; end

[T,N] = size(dZ);

normClose = CumsumNan(dZ);
emaLong = Ema(normClose,1/aLong);
emaShort = Ema(normClose,1/aShort);
pos=lvcf(emaShort-emaLong);

TFpos = nan(T,N);

for t = 1:T
  Q = corrMat(:,:,t);
  activeI = logical(any(Q).*(~isnan(pos(t,:))));
  w_t = pos(t,activeI);
  TFpos(t,activeI) = w_t*target_volatility/sqrt(w_t(:)'*Q(activeI,activeI)*w_t(:));
end
  

end

