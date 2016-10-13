function [w] = lesADMM(Y, mu)
  
  A = Y'*Y;
  C = 1;
  mu = mu(:);
  lambda = C/(mu'*(A\mu));
  w0 = mu/norm(mu);
  
  z=w0(:); u=zeros(length(w0),1);  
  tol = 10^-4; max_norm = 1;
  rho = 0.5;
  tau = 2; mult = 10;
  
  [H,D] = eig(A);
  while max_norm>tol
    x_new = H*diag(1./(diag(D) + rho))*H'*(z - u);
    %x_new(end-q+1:end) = max([x_new(end-q+1:end), zeros(q,1)],[],2);
    %Ax = A*x_new;
    z_new = lambda/rho*mu + rho*(x_new + u);
    u_new = u + (x_new - z_new);
    s = norm(rho*(z-z_new));
    r =  norm(u_new-u);
    [rho, u_new] = updateRho(s,r,rho,u_new);
    max_norm = max(s,r);
    z = z_new; u = u_new;
  end
  w = x_new;

  
  function [rho, u_new] = updateRho(s,r,rho,u_new)
    if r/s > mult
      rho = tau*rho; u_new = u_new/tau;
    elseif r/s < 1/mult
      rho = rho/tau; u_new = u_new*tau;
    end
  end

end