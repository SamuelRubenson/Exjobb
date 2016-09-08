function [ w ] = RP_newton( w0, sigma, target_vol )

  tol = 10^(-8);
  diff = inf;
  nabla = 0.1; %penalty
  w = w0;
  while diff>tol
    p = getDirection(w, nabla, sigma, target_vol);
    alpha = armijoStep(w, p, nabla, sigma, target_vol);
    w_next = w + alpha*p;
    diff = norm(w-w_next);
    nabla = nabla*2;
    w = w_next;
  end




  function p = getDirection(w, nabla, sigma, target_vol)
    dF = gradient(w, nabla, sigma, target_vol);
    H = hessian(w, nabla, sigma, target_vol);
    p = -dF\H;
    p = p(:);
  end



  function [ alpha ] = armijoStep(w, p, nabla, sigma, target_vol)
    mu = 0.05;
    alpha = 1;

    while objective(w + alpha*p, nabla, sigma, target_vol) - objective(w, nabla, sigma, target_vol) > alpha*mu*gradient(w, nabla, sigma, target_vol)'*p
      alpha = alpha/2;
    end
  end


  function [ out ] = objective(w, nabla, sigma, target_vol)
   out = -sum(log(w)) + nabla*max(0, w'*sigma*w - target_vol^2);
  end

  function [df_x] = gradient(w, nabla, sigma, target_vol)
    if w'*sigma*w<=target_vol^2
      df_x = -1./w;
    else
      df_x = -1./w + 2*nabla*sigma*w;
    end
  end

  function [df_x] = hessian(w, nabla, sigma, target_vol)
    if w'*sigma*w<=target_vol^2
      df_x = diag(1./(w.^2));
    else
      df_x = diag(1./(w.^2)) + 2*nabla*sigma;
    end
  end
  

end

