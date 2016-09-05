function [ RPpos ] = getRPpos(signals, corrMat, params)

  [T,N] = size(signals);
  
  RPpos = nan(T,N);
  
  for t = 2:T
    if mod(t,100)==0, disp(t); end
    Q = (corrMat(:,:,t) + corrMat(:,:,t)')/2; %sym
    activeI = logical(any(Q).*(~isnan(signals(t,:))));
    if ~any(activeI), continue; end
    w0 = signals(t,activeI)';
    warning('off', 'optim:fminunc:SwitchingMethod');
    fmin_options = optimset('Display', 'off') ;
    [w_t, ~, exitflag] = fminunc(@(w)-objective(w),w0,fmin_options);
    if exitflag < 1
      fprintf('RP: fmincon failed to find optimum, extitflag: %d \n', exitflag)
    end
    RPpos(t,activeI) = w_t';
%     portfolio_volatility = sqrt( w_t' * sigma * w_t );
%     scaled_weights = params.target_volatility / portfolio_volatility * w_t;
%     w_t = scaled_weights;

  end
  
  
  function [value] = objective(w)
    value = sum(log(abs(w)));
  end
  
end