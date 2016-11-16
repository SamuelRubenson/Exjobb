function [w] = RP_ADMM(corrMat, target_volatility, signal, option)
  
  signal = signal(:);
  switch option
    case 'RP'
      strength = ones(size(signal));
    case 'RPmod'
      strength = abs(signal);
    otherwise
      error('Provide viable RP option')
  end
  
  Q = adjustForSigns(corrMat, sign(signal));
  
  w0 = ones(size(signal))*0.9*target_volatility/sqrt(sum(sum(Q)));
  mu = sum(strength)/target_volatility^2/2;
  
  z=w0(:); u=zeros(length(w0),1);  
  tol = 10^-10; max_norm = 1;
  rho = 0.5;
  tau = 2; mult = 10;
  
  [H,D] = eig(Q);
  while max_norm>tol
    x_new = 1/2*((z-u) + sqrt((z-u).^2 + 4*strength/rho));
    z_new = rho*H*diag(1./(diag(2*mu*D)+rho))*H'*(x_new+u);
    u_new = u + (x_new-z_new);
    s = norm(rho*(z-z_new));
    r =  norm(u_new-u);
    max_norm = max(s,r);
    [rho, u_new] = updateRho(s,r,rho,u_new);
    z = z_new; u = u_new;
  end
  w = x_new(:).*sign(signal);

  
  
  
  function [C_adj] = adjustForSigns(C, signal)
    tmp = repmat(signal,1,size(C,1));
    signs = tmp.*tmp';
    C_adj = C.*signs;
  end
  
  function [rho, u_new] = updateRho(s,r,rho,u_new)
    if r/s > mult
      rho = tau*rho; u_new = u_new/tau;
    elseif r/s < 1/mult
      rho = rho/tau; u_new = u_new*tau;
    end
  end


end