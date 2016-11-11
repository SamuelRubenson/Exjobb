function [w] = testADMM(Y,c, signal, alpha, lambda)
  
  YT = Y';
  [q,N] = size(Y);
  %C = 1;
  %w0 = ones(size(b));
  
  z=alpha; u=zeros(q,1);  
  tol = 10^-4; max_norm = 1;
  rho = 1;
  tau = 1.25; mult = 10;
  
  %subSize = [q, 3];
  cMat = repmat(c,1,3);
  alphaMat = repmat(alpha,1,3);
  [H, D] = eig(Y'*Y, 'vector');
  while max_norm>tol
    %g0 = (lambda*eye(N) + rho*YTY)\(rho*YT*v); %g1 = (lambda*eye(N) + rho*YTY)\signal;
    tmp = (rho*D + lambda);
    g0 =  H*((H'*(rho*YT*(z-u))) ./ tmp);    
    g1 = H*((H'*signal) ./ tmp);
    coeff = max(0, (1-signal'*g0)/(signal'*g1));
    x_new = g0 + coeff*g1;
    %
    Yx = Y*x_new;
    v = Yx + u;
    possible = [-alpha, min(-alpha, c/rho + v), max(v,-alpha)];
    [~,best] = min(cMat.*(-min(0,possible + alphaMat)) + rho/2*(possible - v).^2,[],2);
    ind = sub2ind([q, 3], (1:q)', best); %repmat(1:3, q,1) == repmat(best,1,3);
    z_new = possible(ind); %sum(possible.*ind,2);
    %
    u_new = u + (Yx - z_new);
    s = rho*norm(z-z_new);
    r =  norm(u_new-u);
    [rho, u_new] = updateRho(s,r,rho,u_new);
    max_norm = max(s,r);
    z = z_new; u = u_new;
  end
  w = x_new;

  
  function [rho, u_new] = updateRho(s,r,rho,u_new)
    if r/s > mult
      rho = tau*rho; u_new = u_new/tau;
      %disp('rho increase')
    elseif r/s < 1/mult
      rho = rho/tau; u_new = u_new*tau;
      %disp('rho decrease')
    end
  end

end