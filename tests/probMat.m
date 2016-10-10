function Y = probMat(X, nPoints)% = outCome.General.dZ(7000:end,1:9);



[T,N] = size(X);
% U = nan(T,N);

F = zeros(T,N);


for iN = 1:N
  F(:,iN) = ksdensity(X(:,iN),X(:,iN),'function','cdf');
end

% for iN = 1:N
%   [f,x] = ecdf(X(:,iN));
%   for t = 1:T
%     if ~isnan(X(t,iN))
%       U(t,iN) = f(find(x>=X(t,iN), 1, 'first'));
%     end
%   end
% end
% U(U==0) = 1e-10; U(U==1) = 1-1e-10;

[Rho,nu] = copulafit('t',F,'Method','ApproximateML');
Y_u = copularnd('t', Rho, nu, nPoints);

Y = zeros(nPoints, N);
for iN = 1:N
  Y(:,iN) = ksdensity(X(:,iN),Y_u(:,iN),'function','icdf');
end

end



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