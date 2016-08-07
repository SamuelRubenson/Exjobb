function [ w ] = MV_Optimize( mu, sigma, params)
  option = params('option');
  k = params('k');
  n = length(mu);
  switch option
    case 'Long'
      nStocks = length(mu);
      w0 = zeros(nStocks,1);
      Aeq = ones(1,nStocks); beq = 1;
      lb = 0*ones(nStocks,1); ub = inf*ones(nStocks,1);
      options = optimset('Display', 'off') ;
      [w,~,exitflag] = fmincon(@(w)-expectedUtility(w, mu, sigma, k), w0, [], [], Aeq, beq, lb, ub, [], options);
      if exitflag < 1
        fprintf('MV: fmincon failed to find optimum, extitflag: %d \n', exitflag)
      end
    case 'LongShort'
      one = ones(n,1);
      w = 1/k*(sigma\ ( mu' + ( ( k*1 - one'*(sigma\(mu')) ) / (one' * (sigma\one) ) )*one ) );
    otherwise
      fprintf('Error: Wrong MV-option: %s \n', option)
      return
  end 
  
  function [value] = expectedUtility(w, mu, sigma, k)
    value = mu*w - k/2*(w'*sigma*w);
  end

end

