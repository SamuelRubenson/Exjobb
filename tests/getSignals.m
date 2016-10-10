function [signals_t, sigma2_t, z_t] = getSignals(data)
  T = size(data,1);
  alpha = 0.99;
  
  sigma2_t = getSigma(data);
  z_t = normalizeReturns(sigma2_t, data);
  signals_t = generateSignals(z_t);
  
  
  
  function[sigma2_t] = getSigma(data)
    sigma2_t = zeros(T,1);
    for it = 2:T
      r_t = (data(it,:) - data(it-1,:));
      sigma2_t(it) = alpha*sigma2_t(it-1) + (1-alpha)*r_t^2;
    end
    sigma2_t(1) = NaN;
  end

  function[z_t] = normalizeReturns(sigma2_t, data)
    z_t = ( data(2:end, :) - data(1:end-1,:) )./ sqrt(sigma2_t(2:end)); %%% sigma_(t-1) ?
  end
  
  function[c_t] = generateSignals(z_t)
    c_t = zeros(T-1,1);
    for it = 1:T-1
      tmp = 0;
      for s = 0:it-1
        tmp = tmp + (1-alpha)*alpha^s.*z_t(it-s);
      end
      c_t(it) = tanh(2*tmp);
    end
  end
end