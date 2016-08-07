function [ output ] = evaluatePerformance(return_data, varargin)

p = inputParser;
p.CaseSensitive = false;

default = false;

addRequired(p, 'return_data', @isnumeric);
addParameter(p,'MV', default)
addParameter(p,'RP', default)
addParameter(p,'LES', default)

parse(p,return_data, varargin{:});

nStocks = size(p.Results.return_data,2);
output = struct;

if isa(p.Results.MV, 'struct')
  runMV(p.Results.MV);
end

if isa(p.Results.RP, 'struct')
  runRP(p.Results.RP)
end

%---------------------------------------------------------------------------

  function [] = runMV(params)

    start = params.start;
    step = params.step;
    risk_level = params.risk_level;
    
    times_to_evaluate = start:step:size(return_data,1)-step;
    T = length(times_to_evaluate);

    store_weights = zeros(T, nStocks, length(risk_level));
    store_capital = zeros(T,length(risk_level));

    for ik = 1:length(risk_level)
      k = risk_level(ik);
      params.k = k;
      fprintf('MV: Processing k = %.1f \n',k)
      [capital, weights] = getPerformance(times_to_evaluate, 'MV', params);
      store_capital(:,ik) = capital;
      store_weights(:,:,ik) = weights;
    end
    
    output.MV = struct('capital', store_capital, 'weights', store_weights, 'times', times_to_evaluate);

  end

%--------------------------------------------------------------------------

  function [] = runRP(params)

    start = params.start;
    step = params.step;
    times_to_evaluate = start:step:size(return_data,1)-step;
    [capital, weights] = getPerformance(times_to_evaluate, 'RP', params);
    output.RP = struct('capital', capital, 'weights', weights, 'times', times_to_evaluate);
  
  end
%--------------------------------------------------------------------------

  function [capital, weights] = getPerformance(times_to_evaluate, model, params) % no k
    weights = [];
    portfolio_returns = [];
    step = params.step;
    for t = times_to_evaluate
      
      switch model
        case 'MV'
          w_t = MV_Optimize(t, return_data, params);
        case 'RP'
          w_t = RP_Optimize(t, return_data, params);
        otherwise
          disp('Error: model not found')
          return
      end
      
      return_at_t_plus_one = sum( w_t .* prod(return_data(t+1:t+step,:)+1 ,1)' );
      portfolio_returns = [portfolio_returns; return_at_t_plus_one];
      weights = [weights; w_t(:)'];
    end
    capital = cumprod(portfolio_returns);
  end



end

