function normPoints = testCorr(dZ)
%Q = outCome.General.corr;
%dZ = outCome.General.dZ;

[T,N] = size(dZ);
dists = nan(T,1);
points = nan(N,N,T);
for t = 1:T
  ind = ~isnan(dZ(t,:));
  points(ind,ind,t) = dZ(t,ind)'*dZ(t,ind);
end
normPoints = normalize(points);  
% 
% for t = 1:T
%   Qt = Q(:,:,t);
%   ind = logical(any(Qt).*any(normPoints(:,:,t)));
%   dists(t) = norm(normPoints(ind,ind,t) - Qt(ind,ind))/sum(ind);
% end
% 
% out = tsmovavg(dists','s',50);
%   
  
  function [C_norm] = normalize(C)
    C_norm = nan(size(C));
    for it = 2:T
      variances = repmat(diag(C(:,:,it)),1,N);
      norm_mat = sqrt(variances'.*variances);
      C_norm(:,:,it) = C(:,:,it)./norm_mat;
    end
  end
end