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

if isa(p.Results.MV, 'containers.Map')
  runMV(p.Results.MV);
end

%---------------------------------------------------------------------------

  function [] = runMV(params)

    start = params('start');
    step = params('step');
    risk_level = params('risk_level');
    
    times_to_evaluate = start:step:size(return_data,1);
    T = length(times_to_evaluate);

    store_weights = zeros(T, nStocks, length(risk_level));
    store_capital = zeros(T,length(risk_level));

    for ik = 1:length(risk_level)
      k = risk_level(ik);
      params('k') = k;
      fprintf('MV: Processing k = %.1f \n',k)
      [capital, weights] = getPerformance(times_to_evaluate, 'MV', params);
      store_capital(:,ik) = capital;
      store_weights(:,:,ik) = weights;
    end
    
    output.MV = struct('capital', store_capital, 'weights', store_weights, 'times', times_to_evaluate);

  end

%--------------------------------------------------------------------------

  function [capital, weights] = getPerformance(times_to_evaluate, model, params) % no k
    weights = [];
    capital = 1;
    step = params('step'); start = params('start');
    for t = times_to_evaluate
      if t>times_to_evaluate(1)
        new_capital = sum( w_t .* prod(p.Results.return_data(t-step+1:t,:) + 1 ,1)' * capital(end) );
        capital = [capital; new_capital];
      end
      
      %w_t = optimalWeights;
      switch model
        case 'MV'
          mu = mean(return_data(t-start+1:t,:),1);
          sigma = cov(return_data(t-start+1:t,:));
          w_t = MV_Optimize(mu, sigma, params);
        otherwise
          disp('Error: model not found')
          return
      end
      weights = [weights; w_t(:)'];
    end
    
  end



end

