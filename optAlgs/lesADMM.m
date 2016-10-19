function [w] = lesADMM(Y, signal, c)
  [nP, nM] = size(Y);
  A = [-Y, -ones(nP,1)];
  f = [signal(:); 1];
  AT = A';
  ATA = A'*A;
  %ATAinv = inv(ATA);
  
  x0 = ones(size(c));
  z=x0(:); u=zeros(length(x0),1);  
  tol = 10^-4; max_norm = 1;
  rho = 0.5;
  tau = 2; mult = 10;
  
  while max_norm>tol
    x_new = ATA\(-f/rho + AT*(z-u));
    %x_new(end-q+1:end) = max([x_new(end-q+1:end), zeros(q,1)],[],2);
    %Ax = A*x_new;
    b = -A*x_new - u;
    z_new = b - 1/rho*(c.*(b>0));
    u_new = u + (A*x_new - z_new);
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