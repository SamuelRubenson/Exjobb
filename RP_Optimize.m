function [ w_t ] = RP_Optimize(t, return_data, params)

  nStocks = size(return_data,1);
  option = params.option;
  
  sigma = cov(return_data(t - params.lookBack_sigma + 1 : t, :));
  inv_volatilities = 1 ./ sqrt( diag(sigma) );
  
  weight_signs = sign(prod( 1 + return_data(t - params.lookBack_returns + 1 : t, :) ,1) -1 ); %%% -1 !?!?!?!?
  weight_signs(weight_signs==0) = 1; %no zeors, objective function undefined
  gross_weights = inv_volatilities / sum(inv_volatilities);
  net_weights = weight_signs(:) .* gross_weights(:);
  
  switch option
    case 'VP-TF'
      
      portfolio_volatility = sqrt(sum(diag(sigma))); % sqrt( net_weights' * sigma * net_weights );
      scaled_weights = params.target_volatility / portfolio_volatility * net_weights;
      w_t = scaled_weights;
      
    case 'RP-LO'
      
      w0 = gross_weights(:);
      lb = zeros(nStocks,1);
      fmin_options = optimset('Display', 'off') ;
      [w_t, exitflag] = fmincon(@(w)-objective(w), w0, [], [], [], [], lb, [], @(w)constraint(w), fmin_options);
      if exitflag < 1
        fprintf('RP: fmincon failed to find optimum, extitflag: %d \n', exitflag)
      end
      w_t = w_t/sum(w_t);
      
    case 'RP-TF'
      
      w0 = net_weights;
      fmin_options = optimset('Display', 'off') ;
      [w_t, ~, exitflag] = fmincon(@(w)-objective(w), w0, [], [], [], [], [], [], @(w)constraint(w), fmin_options);
      if exitflag < 1
        fprintf('RP: fmincon failed to find optimum, extitflag: %d \n', exitflag)
      end
      portfolio_volatility = sqrt( w_t' * sigma * w_t );
      scaled_weights = params.target_volatility / portfolio_volatility * w_t;
      w_t = scaled_weights;
      
  end
  
  
  function [value] = objective(w)
    value = sum(log(abs(w)));
  end

  function [c, ceq] = constraint(w)
    c = sqrt(w'*sigma*w) - params.target_volatility;
    ceq = [];
  end
  
end