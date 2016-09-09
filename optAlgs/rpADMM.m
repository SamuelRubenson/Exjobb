function [w] = rpADMM(w0,Q,mu)
z=w0(:); u=zeros(length(w0),1);  
tol = 10^-6; conv = 1;
rho = 1;

[H,D] = eig(Q);
while conv>tol
  x_new = max( [1/2*((u-z) + sqrt((u-z).^2 + 4/rho)), 1/2*((u-z) - sqrt((u-z).^2 + 4/rho))]...
    , [], 2);
  z_new = rho*( (2*mu*Q + rho*eye(size(Q,1)))\(-x_new-u) );
  u_new = u + abs(x_new-z_new);
  s = norm(rho*(z-z_new));
  r =  norm(u_new-u);
  conv = max( s,r);
  z = z_new; u = u_new;
end

w = x_new;