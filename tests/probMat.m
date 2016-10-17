function [testPos, times, assets, lookBack] = probMat(outCome, Config , Y, M)
clc
options = optimoptions('fmincon', 'GradObj','on', 'Display', 'off');
assets = find(M);
times = 1:9485;
quantiles = 0.05;

dZ = outCome.General.dZ(:,M);  nPoints = 10000; lookBack = 504;
signals = outCome.Models.TF.pos(:,M);
Q = outCome.General.corr(M,M,:);

%storeY = nan(nPoints, length(assets), length(times));
%storeY_u = nan(nPoints, length(assets), length(times));

testPos = nan(length(times), length(assets));
for t = times(lookBack:end)
t
X = dZ(t-lookBack+1:t,:);
s = signals(t,:);
activeI = logical(all(~isnan(X),1).*(~isnan(s)));
if ~any(activeI), continue; end

% X = X(:,activeI);
% [T,N] = size(X);
% % U = nan(T,N);
% F = zeros(T,N);
% for iN = 1:N
%   F(:,iN) = ksdensity(X(:,iN),X(:,iN),'function','cdf');
% end
% [Rho,nu] = copulafit('t',F,'Method','ApproximateML');
% Y_u = copularnd('t', Rho, nu, nPoints);

% Y = zeros(size(Y_u));
% for iN = 1:N
%   Y(:,iN) = ksdensity(X(:,iN),Y_u(:,iN),'function','icdf');
% end
% Y = Y.*(abs(Y_u-0.5)>=0.5-quantiles); %quantiles



%Y = sign(Y_u-0.5).*((Y_u-0.5).^2);
%Y = (Y_u-0.5).*(abs(Y_u-0.5)>=0.5-quantiles)*10; %use
%Y = Y.*repmat(sign(s(activeI)), nPoints, 1);

%c = ones(nPoints,1);

%[x, ~, exitflag] = fmincon(@(x) objTest(Y(:,activeI), x) , s(activeI)'/norm(s(activeI)), -s(activeI),-1, [], [], [], [], [], options);
%if exitflag<=0, disp('-------------------------------'); disp(exitflag); end
%x = fmincon(@(x) norm(Y*x,2) , 0.1*ones(N,1), [],[], ones(1,N), 1, zeros(N,1), []);
x = lesADMM(Y(:,activeI), s(activeI));

out = nan(length(assets),1);
out(activeI) = x(:)*Config.target_volatility/sqrt(x(:)'*Q(activeI,activeI,t)*x(:)); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
testPos(t,:) = out;
end


end



% Y = zeros(nPoints, N);
% for iN = 1:N
%   Y(:,iN) = ksdensity(X(:,iN),Y_u(:,iN),'function','icdf');
% end







% for iN = 1:N
%   [f,x] = ecdf(X(:,iN));
%   for t = 1:T
%     if ~isnan(X(t,iN))
%       U(t,iN) = f(find(x>=X(t,iN), 1, 'first'));
%     end
%   end
% end
% U(U==0) = 1e-10; U(U==1) = 1-1e-10;

%end



% q = 0.1;
% 
% V = nan(N,N);
% 
% for i =1:N
%   for j = 1:N
%     V(i,j) = nanmean( (U(:,i)<=q).*(U(:,j)<=q) );
%   end
% end
% V = V;
% V = repmat(V,1,1,T);