function [ Y ] = getRandPoints( X, nPoints  )

[T,N] = size(X);
% U = nan(T,N);
F = zeros(T,N);
for iN = 1:N
  F(:,iN) = ksdensity(X(:,iN),X(:,iN),'function','cdf');
end
[Rho,nu] = copulafit('t',F,'Method','ApproximateML');
Y_u = copularnd('t', Rho, nu, nPoints);

Y = zeros(size(Y_u));
for iN = 1:N
  Y(:,iN) = ksdensity(X(:,iN),Y_u(:,iN),'function','icdf');
end


end

