dZ = outCome.General.dZ;
Q = outCome.General.corr;
[T, N] = size(dZ);

error = nan(T,1);
for t = 2:T
  n = sum(~isnan(dZ(t,:)));
  point_est = dZ(t,:)'*dZ(t,:);
  difff = abs(Q(:,:,t)).*(~eye(N));
  error(t) = NansumNan(NansumNan(difff))/n^2;
end
figure(), plot(dates, tsmovavg(error,'s',1,1))
