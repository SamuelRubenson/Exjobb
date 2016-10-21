function [w] = testADMM(Y, mu, alpha)
  [~, nM] = size(Y);
  lambda = 5;
  x_new = rand(nM,1);
  z=x_new; u=zeros(nM,1);  
  tol = 10^-6; max_norm = 1;
  rho = 0.5;
  tau = 2; mult = 10;
  
  while max_norm>tol
    Y2 = Y((Y*x_new+alpha)<0,:);
    nP = size(Y2,1);
    x_new = (Y2'*Y2 + rho*eye(nM)) \ (rho*(z-u) - alpha*Y2'*ones(nP,1) );
    z_new = lambda/rho*mu + x_new + u;
    u_new = u + (x_new-z_new);
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
