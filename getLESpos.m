function [pos] = getLESpos( dZ, signals, corrMat, lookBack,  target_volatility, beta )
lookBack
[T,N] = size(signals);

options = optimoptions('linprog','Algorithm','dual-simplex', 'Display', 'off');
%options = optimoptions('linprog','Display', 'off');

pos = nan(T,N);
q = lookBack;
%tau = 100;
%a = 1-1/tau;
%c = filter(1-a, [1 -a], [1; zeros(q-1,1)]);
%c = c/sum(c);
c = ones(q,1)/q;

parfor t = q+1:T
  y = dZ(t-q+1:t,:);
  s = signals(t,:);
  activeI = logical(all(~isnan(y),1).*(~isnan(s)));
  if ~any(activeI), continue; end
  
  n = sum(activeI);
  %A = [-y(:,activeI), -ones(q,1), -eye(q); diag(-s(activeI)'), zeros(n,1), zeros(n,q)];
  %b = [zeros(q, 1); -0.01*ones(n,1)];
  A = [-y(:,activeI), -ones(q,1), -eye(q); -s(activeI), 0, zeros(1,q)];
  b = [zeros(q, 1); -1];
  lb = [-inf*ones(n,1); -inf; zeros(q,1)];
  f = [zeros(n,1); 1; c/(1-beta)];
  [opt, fval, exitflag] = linprog(f,A,b,[],[],lb,[], zeros(n,1), options);
  %opt = lesADMM(y, q, activeI);
  %opt = fmincon(@(x) x(1) + 1/(q*(1-beta))*sum(max([y(:,activeI)*x(2:end), zeros(q,1)],[],2)),...
  %  1/n*ones(n+1,1));
  
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