function [ TFpos, tau ] = getTFpos(dZ, corrMat, aLong, aShort, target_volatility)

if isempty(aLong), aLong = 200; end
if isempty(aShort), aShort = 10; end

x = [1; zeros(10000-1,1)];
a = 1-1/aLong; a2 = 1-1/aShort;
y1 = filter(1-a,[1, -a],x); y2 = filter(1-a2,[1, -a2],x);
y3 = cumsum(y2)-cumsum(y1); y3 = y3/sum(y3);
tau = sum((1:10000)'.*y3);


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

