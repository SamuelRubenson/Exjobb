function [pos] = getTESTpos( dZ, signals, corrMat, lookBack,  target_volatility, beta )
lookBack
Npoints = 5000;

[T,N] = size(signals);

options = optimoptions('linprog','Algorithm','dual-simplex', 'Display', 'off');
options2 = optimoptions('fmincon','Display', 'off','GradObj','on');

pos = nan(T,N);
q = lookBack;
alpha = beta;

M = ~isnan(dZ(2,:));
%Y = getRandPoints(dZ(2:lookBack,M), Npoints);
%Y = getRandPoints(dZ(9200:9452,:), Npoints);
%Y = dZ(9300-lookBack+1:9300,:);

maxM = sum(M); n = 14;

for t = q+1:T
  t
  M = ~isnan(dZ(t-lookBack+1,:));
  s = signals(t,:);
  activeI = logical(M.*(~isnan(s)));
  if ~any(activeI), continue; end
  
  if sum(activeI)>maxM % new market
    %Y = getRandPoints(dZ(t-lookBack+1:t,M), Npoints);
    Y = dZ(t-lookBack+1:t,activeI);
    maxM = sum(activeI);
  else
    nPoints = floor(Npoints/100);
    %y = getRandPoints(dZ(t-lookBack+1:t,M), nPoints);
    %Y = [Y(nPoints+1:end,:); y];
    Y = dZ(t-lookBack+1:t,activeI);
  end
  
  n = sum(activeI);
  
%   A = [-Y(:,activeI), -eye(Npoints); -s(activeI), zeros(1,Npoints)];
%   b = [alpha*ones(Npoints, 1); -1];
%   lb = [-inf*ones(n,1); zeros(Npoints,1)];
%   f = [zeros(n,1); ones(Npoints,1)];
  %[opt, fval, exitflag] = linprog(f,A,b,[],[],lb,[], zeros(n,1), options);
  
  opt = testADMM(Y, s(activeI)', alpha);
  exitflag = (s(activeI)*opt)>0;
  
  %lambda = [1, 0.125];
  %opt = ( (lambda(1)*Q + lambda(2)*(Y'*Y)) \ (2*s(activeI)' - alpha*lambda(2)*Y'*ones(lookBack,1)) );
  %exitflag=1;
  
  %[opt, ~, exitflag] = fmincon(@(x)obj(x,Y), s(activeI)', -s(activeI),-1,[],[],[],[],[],options2);
  
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

  function [f, g] = obj(x, Y)
    Y2 = Y((Y*x+alpha)<0,:);
    f = norm(Y2*x+alpha);
    g = Y2'*(Y2*x+alpha);
  end

end