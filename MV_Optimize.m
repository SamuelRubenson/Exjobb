function [ w ] = MV_Optimize( mu, sigma, k )
  
  nStocks = length(mu);
  w0 = zeros(nStocks,1);
  Aeq = ones(1,nStocks); beq = 1;
  lb = 0*ones(nStocks,1); ub = ones(nStocks,1);
  options = optimset('Display', 'off') ;
  [w,~,exitflag] = fmincon(@(w)-objective(w, mu, sigma, k), w0, [], [], Aeq, beq, lb, ub, [], options);
  if exitflag < 1
    disp('we have a problem')
  end
  
  function [value] = objective(w, mu, sigma, k)
    value = mu*w - k/2*(w'*sigma*w);
  end

end

