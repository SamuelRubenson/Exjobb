function [w] = rpADMM(Q, target_volatility, signal)
  if ~exist('signal', 'var'), signal = ones(size(Q,1),1); end

  w0 = ones(size(signal));%*0.9*target_volatility/sqrt(sum(sum(Q)));
  mu = sum(abs(signal))/target_volatility^2/2;
  
  z=w0(:); u=zeros(length(w0),1);  
  tol = 1e-8; max_norm = 1;
  rho = 0.5;
  tau = 1.5; mult = 2;
  
  [H,D] = eig(Q,'vector');
  while max_norm>tol
    x_new = 1/2*((z-u) + sqrt((z-u).^2 + 4*abs(signal(:))/rho));
    %z_new = rho*H*diag(1./(diag(2*mu*D)+rho))*H'*(x_new+u);
    z_new = rho * (H*((H'*(x_new+u)) ./ (2*mu*D+rho)));
    u_new = u + (x_new-z_new);
    s = rho*norm((z-z_new));
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
