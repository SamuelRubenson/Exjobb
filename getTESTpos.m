function [pos] = getTESTpos( dZ, signals, corrMat, lookBack,  target_volatility, beta )

Npoints = 5000;

[T,N] = size(signals);

options = optimoptions('linprog','Algorithm','dual-simplex', 'Display', 'off');
%options = optimoptions('linprog','Display', 'off');

pos = nan(T,N);
q = lookBack;
alpha = -1;

M = ~isnan(dZ(2,:));
Y = getRandPoints(dZ(2:lookBack,M), Npoints);

maxM = sum(M);

for t = q+1:T
  t
  M = ~isnan(dZ(t-lookBack+1,:));
  s = signals(t,:);
  activeI = logical(M.*(~isnan(s)));
  if ~any(activeI), continue; end
  
  if sum(activeI)>maxM % new market
    Y = getRandPoints(dZ(t-lookBack+1:t,M), Npoints);
    %Y = dZ(t-lookBack+1:t,M);
    maxM = sum(activeI);
  else
    nPoints = floor(Npoints/20);
    y = getRandPoints(dZ(t-lookBack+1:t,M), nPoints);
    Y = [Y(nPoints+1:end,:); y];
    %Y = dZ(t-lookBack+1:t,M);
  end
  
  n = sum(activeI);
  %A = [-y(:,activeI), -ones(q,1), -eye(q); diag(-s(activeI)'), zeros(n,1), zeros(n,q)];
  %b = [zeros(q, 1); -0.01*ones(n,1)];
  A = [-Y, -eye(Npoints); -s(activeI), zeros(1,Npoints)];
  b = [alpha*ones(Npoints, 1); -1];
  lb = [-inf*ones(n,1); zeros(Npoints,1)];
  f = [zeros(n,1); ones(Npoints,1)];
  [opt, fval, exitflag] = linprog(f,A,b,[],[],lb,[], zeros(n,1));
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