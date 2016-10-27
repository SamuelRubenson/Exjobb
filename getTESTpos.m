function [pos] = getTESTpos( dZ, signals, corrMat, lookBack,  target_volatility, beta )

[T,N] = size(signals);

%options = optimoptions('linprog','Algorithm','dual-simplex', 'Display', 'off');
options = optimoptions('quadprog','Display', 'off');
dZnorm = nan(size(dZ));
for t = 1:T
  y = dZ(t,:);
  activeI = ~isnan(y);
  dZnorm(t,activeI) = dZ(t,activeI)/norm(dZ(t,activeI));
end


x = [1; zeros(800,1)];
a = 1-1/100; a2 = 1-1/200;
y1 = filter(1-a2,[1, -a2],x); 
y2 = filter(1-a,[1, -a],filter(1-a,[1, -a],x));
y3 = (y1 + 1.5*y2);

pos = nan(T,N);
q = lookBack;
alpha = -.5;
C = 1;
c = (1:q)'/q;

tmp = sum(~isnan(dZ),2);
tmp = [tmp(1:q); tmp(1:end-q)];

for t = q+1:T
  t
  %q = 6*tmp(t);
  y = dZnorm(t-q+1:t,:);
  s = signals(t,:);
  activeI = logical(all(~isnan(y),1).*(~isnan(s)));
  if ~any(activeI), continue; end
  n = sum(activeI);
  s = s(activeI)/norm(s(activeI));
  
  H = 2*[eye(n), zeros(n,q); zeros(q, n+q)];
  A = [-y(:,activeI), -eye(q); -s, zeros(1,q)];
  b = [alpha*ones(q, 1); -C];
  lb = [-inf*ones(n,1); zeros(q,1)];
  f = [zeros(n,1); c];
  [opt, fval, exitflag] = quadprog(H,f,A,b,[],[],lb,[], zeros(n,1), options);


  if exitflag>=0
    x = opt(1:n);
    norm(x)
    %alpha = opt(n+1);
    x = x*target_volatility/sqrt(x(:)'*corrMat(activeI,activeI,t)*x(:));
    out = nan(1,N);
    out(activeI) = x;
    pos(t,:) = out;
    if exitflag==0, disp('Max-iter hit'); end
  else
    fprintf('No solution, exitflag: %d \n', exitflag)
  end
end


end