function [pos] = getLESpos( dZ, signals, corrMat, assetClasses,  target_volatility, lambda )

[T,N] = size(signals);


pos = nan(T,N);
q = 252;
beta = 0.95;

for t = q+1:T
  y = dZ(t-q+1:t,:);
  activeI = all(~isnan(y),1);
  n = sum(activeI);
  A = [-y(:,activeI), -ones(q,1), -eye(q); -signals(t,activeI), 0, zeros(1,q)];
  b = [zeros(q, 1); -1];
  lb = [-inf*ones(n,1); -inf; zeros(q,1)];
  f = [zeros(n,1); 1; 1/(q*(1-beta))*ones(q,1)];
  opt = linprog(f,A,b,[],[],lb,[]);
  x = opt(1:n);
  x = x*target_volatility/sqrt(x(:)'*corrMat(activeI,activeI,t)*x(:));
  alpha = opt(n+1);
  pos(t,activeI) = x;
  t
end


end