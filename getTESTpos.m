function [pos, mNorm, dev] = getTESTpos( dZ, signals, corrMat, lookBack,  target_volatility, beta, lambda )

[T,N] = size(signals);

%options = optimoptions('linprog','Algorithm','dual-simplex', 'Display', 'off');
options = optimoptions('quadprog','Display', 'off');

dZnorm = nan(size(dZ));
for t = 1:T
  y = dZ(t,:);
  activeI = ~isnan(y);
  dZnorm(t,activeI) = dZ(t,activeI)/norm(dZ(t,activeI));
end


normen = nan(T,1);
constr = nan(T,1);


q = lookBack;
%alpha = beta;
C = 1;

%alpha = [-0.5, -0.2, 0.1];
alpha = [-0.75, -0.5, -0.25, -0.1, 0, 0.1];
nAlpha = numel(alpha);
nAux = nAlpha*q;
bb = ones(nAux,1);
c = [];
for i = 1:nAlpha
  bb( (i-1)*q + 1 : i*q ) = ones(q,1)*alpha(i);
  c = [c; (1:q)'/q/i];
end

%c = repmat((1:q)'/q, nAlpha, 1)/nAlpha;
%c = ones(nAux,1)/nAux;

pos = nan(T,N);
parfor t = q+1:T
  t
  %q = 6*tmp(t);
  y = dZnorm(t-q+1:t,:);
  s = signals(t,:);
  activeI = logical(all(~isnan(y),1).*(~isnan(s)));
  if ~any(activeI), continue; end
  n = sum(activeI);
  s = s(activeI)/norm(s(activeI));
  
  H = lambda*[eye(n), zeros(n,nAux); zeros(nAux, n+nAux)];
  Y = repmat(-y(:,activeI), nAlpha, 1);
  A = [Y, -eye(nAux); -s, zeros(1,nAux)];
  b = [bb; -C];
  lb = [-inf*ones(n,1); zeros(nAux,1)];
  f = [zeros(n,1); c];
  
  [opt, fval, exitflag] = quadprog(H,f,A,b,[],[],lb,[], [], options);
  
%   options = optimoptions(@fmincon,'Algorithm','interior-point',...
%     'SpecifyObjectiveGradient',true,'SpecifyConstraintGradient',true,...
%     'HessianFcn',@(x,lambda)quadhess(x,lambda,H));
%   [opt,~,exitflag] = fmincon(@(x)quadobj(x,f),zeros(size(f)),...
%     [],[],[],[],lb,[],@(x)quadconstr(x,H,A,b,2),options);
  
  if exitflag>=0
    x = opt(1:n);
    %norm(x)
    normen(t) = norm(x);
    constr(t) = s*x;
    %alpha = opt(n+1);
    x = x*target_volatility/sqrt(x(:)'*corrMat(activeI,activeI,t)*x(:));

    thisPos = nan(1,N);
    thisPos(activeI) = x;
    
%     prevInd = ~isnan(pos(t-1,:));
%     thisPos(prevInd) = 3/4*pos(t-1,prevInd) + 1/4*thisPos(prevInd);
    
    pos(t,:) = thisPos;
    if exitflag==0, disp('Max-iter hit'); end
  else
    fprintf('No solution, exitflag: %d \n', exitflag)
  end
end

pos2 = pos;
for t = 2:size(pos,1)
  ind = ~isnan(pos2(t-1,:));
  pos2(t,ind) = (1-1/4)*pos2(t-1,ind) + 1/4*pos2(t,ind);
end
pos = pos2;

mNorm = nanmean(normen);

dev = constr./normen;
%figure(30), hold on, plot(normen), plot(constr./normen)

end