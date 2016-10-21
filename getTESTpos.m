function [pos] = getTESTpos( dZ, signals, corrMat, lookBack,  target_volatility, beta )

Npoints = 5000;

[T,N] = size(signals);

options = optimoptions('linprog','Algorithm','dual-simplex', 'Display', 'off');
%options = optimoptions('linprog','Display', 'off');

pos = nan(T,N);
q = lookBack;
alpha = -0.5;

M = ~isnan(dZ(2,:));
Y = getRandPoints(dZ(2:lookBack,M), Npoints);
%Y = getRandPoints(dZ(9200:9452,:), Npoints);

maxM = sum(M);

for t = q+1:T
  if t>2000, continue; end
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
    nPoints = floor(Npoints/100);
    y = getRandPoints(dZ(t-lookBack+1:t,M), nPoints);
    Y = [Y(nPoints+1:end,:); y];
    %Y = dZ(t-lookBack+1:t,M);
  end
  
  n = sum(activeI);
  
%   A = [-Y(:,activeI), -eye(Npoints); -s(activeI), zeros(1,Npoints)];
%   b = [alpha*ones(Npoints, 1); -1];
%   lb = [-inf*ones(n,1); zeros(Npoints,1)];
%   f = [zeros(n,1); ones(Npoints,1)];
  %[opt, fval, exitflag] = linprog(f,A,b,[],[],lb,[], zeros(n,1), options);
  opt = testADMM(Y, s(activeI)', alpha);
  exitflag = (s(activeI)*opt)>0;
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