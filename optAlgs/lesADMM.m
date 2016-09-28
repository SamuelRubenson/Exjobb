function [w] = lesADMM(y, q, activeI)
  beta = 0.6;
  A = [-ones(q,1), -y(:,activeI), -eye(q)];
  c = [1; zeros(n,1); 1/(q*(1-beta))*ones(q,1)];
  w0 = ones(size(c));
  
  z=w0(:); u=zeros(length(w0),1);  
  tol = 10^-4; max_norm = 1;
  rho = 0.5;
  tau = 2; mult = 10;
  
  while max_norm>tol
    x_new = A\(-c/rho + z - u);
    x_new(end-q+1:end) = max([x_new(end-q+1:end), zeros(q,1)],[],2);
    Ax = A*x_new;
    z_new = max( [Ax+u zeros(size(A,1),1)],[],2);
    u_new = u + (Ax-z_new);
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