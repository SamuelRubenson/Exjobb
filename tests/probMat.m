function V = probMat(X)% = outCome.General.dZ(7000:end,1:9);

[T,N] = size(X);
U = nan(T,N);

for iN = 1:N
  [f,x] = ecdf(X(:,iN));
  for t = 1:T
    if ~isnan(X(t,iN))
      U(t,iN) = f(find(x>=X(t,iN), 1, 'first'));
    end
  end
end

q = 0.1;

V = nan(N,N);

for i =1:N
  for j = 1:N
    V(i,j) = nanmean( (U(:,i)<=q).*(U(:,j)<=q) );
  end
end
V = V;
V = repmat(V,1,1,T);