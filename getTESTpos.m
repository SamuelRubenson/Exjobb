function [pos] = getTESTpos( dZ, signals, corrMat, lookBack,  target_volatility, beta )

[T,N] = size(signals);

options = optimoptions('linprog','Algorithm','dual-simplex', 'Display', 'off');
%options = optimoptions('linprog','Display', 'off');

pos = nan(T,N);
q = lookBack;
c = ones(q,1);

for t = q+1:T
  
  y = dZ(t-q+1:t,:);
  s = signals(t,:);
  activeI = logical(all(~isnan(y),1).*(~isnan(s)));
  if ~any(activeI), continue; end
  n = sum(activeI);
  
  A = [-y(:,activeI), -eye(q); -s(activeI), zeros(1,q)];
  b = [zeros(q, 1); -1];
  lb = [-inf*ones(n,1); zeros(q,1)];
  f = [zeros(n,1); ones(q,1)];
  [opt, fval, exitflag] = linprog(f,A,b,[],[],lb,[], zeros(n,1), options);


  if exitflag>=0
    x = opt(1:n);
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