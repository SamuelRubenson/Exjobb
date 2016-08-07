function [ w_t ] = RP_Optimize(t, return_data, params)
  
  nStocks = size(return_data,1);
  option = params.option;
  
  sigma = cov(return_data(t - params.lookBack_sigma + 1 : t, :));
  inv_volatilities = 1 ./ sqrt( diag(sigma) );
  
  switch option
    case 'VP-TF'
      weight_signs = sign(prod( return_data(t - params.lookBack_returns + 1 : t, :) + 1 , 1 ));
      gross_weights = inv_volatilities / sum(inv_volatilities);
      net_weights = weight_signs(:) .* gross_weights(:);
      
      portfolio_volatility = sqrt(sum(diag(sigma))); % sqrt( net_weights' * sigma * net_weights );
      
      scaled_weights = params.target_volatility / portfolio_volatility * net_weights;
      sum(scaled_weights)
      w_t = net_weights;
  end
      
      
  
end