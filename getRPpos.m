function [ RPpos ] = getRPpos(signals, corrMat, target_volatility)

  [T,N] = size(signals);
 
  RPpos = nan(T,N);
  
  for t = 2:T
    Q = corrMat(:,:,t);
    if mod(t,1000)==0, disp(t); end
    activeI = logical(any(Q).*(~isnan(signals(t,:))));
    if ~any(activeI), continue; end
    w0 = sign(signals(t,activeI)');
    fmin_options = optimset('Display', 'off') ;
%     [w_t, ~, exitflag] = fmincon(@(w)-objective(w),w0,[],[],[],[],[],[],...
%       @(w)constraint(w,Q(activeI,activeI)),fmin_options);
    [w_t,~,exitflag] = fsolve(@(w)F(w,Q(activeI,activeI)),w0,fmin_options);
    if exitflag < 1
      fprintf('RP: fmincon failed to find optimum, extitflag: %d \n', exitflag)
    end
    RPpos(t,activeI) = w_t';
  end
  
  
  function [value] = objective(w)
    value = sum(log(abs(w)));
  end

  function [c, ceq] = constraint(w, sigma)
    c = sqrt(w'*sigma*w)-target_volatility;
    ceq = [];
  end

  function [value] = F(w, sigma)
    n = size(sigma,1);
    value = w(:).*(sigma*w(:)) - target_volatility^2/n*ones(n,1);
  end
  
end