function [ w ] = MV_Optimize( t, return_data, params)
  
  k = params.k;
  nStocks = size(return_data,2);
  option = params.option;
  
  mu = mean(return_data(t-params.lookBack_mu+1:t,:),1);
  sigma = cov(return_data(t-params.lookBack_sigma+1:t,:));
  
  switch option
    case 'Long'
      nStocks = length(mu);
      w0 = zeros(nStocks,1);
      Aeq = ones(1,nStocks); beq = 1;
      lb = 0*ones(nStocks,1); ub = inf*ones(nStocks,1);
      fmin_options = optimset('Display', 'off') ;
      [w,~,exitflag] = fmincon(@(w)-expectedUtility(w, mu, sigma, k), w0, [], [], Aeq, beq, lb, ub, [], fmin_options);
      if exitflag < 1
        fprintf('MV: fmincon failed to find optimum, extitflag: %d \n', exitflag)
      end
    case 'LongShort'
      one = ones(nStocks,1);
      w = 1/k*(sigma\ ( mu' + ( ( k*1 - one'*(sigma\(mu')) ) / (one' * (sigma\one) ) )*one ) );
    otherwise
      fprintf('Error: Wrong MV-option: %s \n', option)
      return
  end 
  
  function [value] = expectedUtility(w, mu, sigma, k)
    value = mu*w - k/2*(w'*sigma*w);
  end

end

