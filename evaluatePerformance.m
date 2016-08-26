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
T = size(p.Results.return_data,1);
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
    risk_level = params.risk_level;

    store_weights = zeros(T-start, nStocks, length(risk_level));
    store_returns = zeros(T-start,length(risk_level));
    for ik = 1:length(risk_level)
      k = risk_level(ik);
      params.k = k;
      fprintf('MV: Processing k = %.1f, option: %s \n', k, params.option)
      [portfolio_returns, weights, times] = getPerformance('MV', params);
      store_returns(:,ik) = portfolio_returns;
      store_weights(:,:,ik) = weights;
    end
    
    output.MV = struct('portfolio_returns', store_returns, 'weights', store_weights, 'times', times);

  end

%--------------------------------------------------------------------------

  function [] = runRP(params)
    fprintf('RP: Processing model %s \n', params.option)
    [portfolio_returns, weights, times] = getPerformance('RP', params);
    output.RP = struct('portfolio_returns', portfolio_returns, 'weights', weights, 'times', times);
  
  end
%--------------------------------------------------------------------------

  function [portfolio_returns, weights, times] = getPerformance(model, params)
    weights = [];
    portfolio_returns = [];
    start = params.start;
    step = params.step;
    times = start:T-1;
    w_t = zeros(nStocks,1);
    for t = times
      
      if mod(t, step)==0
        switch model
          case 'MV'
            w_t = MV_Optimize(t, return_data, params);
          case 'RP'
            w_t = RP_Optimize(t, return_data, params);
          otherwise
            disp('Error: model not found')
            return
        end
      end
      
      surplus_or_loan = 1 - sum(w_t); r = 0; %%%%%%%%%%% set rate?
      return_at_t_plus_one = (return_data(t+1,:)+1)*w_t(:) + surplus_or_loan*(1+r) - 1;
      portfolio_returns = [portfolio_returns; return_at_t_plus_one];
      weights = [weights; w_t(:)'];
    end
    times = times + 1; % to correspond to correct return
  end



end

