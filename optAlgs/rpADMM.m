function [w] = rpADMM(w0,Q,mu, signal)
z=w0(:); u=zeros(length(w0),1);  
tol = 10^-10; max_norm = 1;
rho = 0.5;
tau = 2; mult = 10;

[H,D] = eig(Q);
%inverse = H*diag(1./(diag(2*mu*D)+rho))*H'; 
while max_norm>tol
  x_new = max( [1/2*((z-u) + sqrt((z-u).^2 + 4*abs(signal(:))/rho)),...
    1/2*((z-u) - sqrt((z-u).^2 + 4*abs(signal(:))/rho))], [], 2);
  z_new = rho*H*diag(1./(diag(2*mu*D)+rho))*H'*(x_new+u);
  u_new = u + (x_new-z_new);
  s = norm(rho*(z-z_new));
  r =  norm(u_new-u);
  if r/s > mult
    rho = tau*rho; u_new = u_new/tau;
  elseif r/s < 1/mult
    rho = rho/tau; u_new = u_new*tau;
  end
  max_norm = max(s,r);
  z = z_new; u = u_new;
end
w = x_new;