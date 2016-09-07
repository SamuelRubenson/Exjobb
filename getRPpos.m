function [ RPpos ] = getRPpos(signals, corrMat, target_volatility)

  [T,N] = size(signals);
 
  RPpos = nan(T,N);
  
  for t = 2:T
    if mod(t,1000)==0, disp(t); end
    Q = corrMat(:,:,t);
    activeI = logical(any(Q).*(~isnan(signals(t,:))));
    if ~any(activeI), continue; end
    
    signal_signs = sign(signals(t,activeI)');
    adjusted_corrMat = adjustForSigns(Q(activeI,activeI),signal_signs);
    w0 = ones(length(signal_signs),1);
    w_t = RP_newton(w0,adjusted_corrMat,target_volatility);
    RPpos(t,activeI) = w_t(:).*signal_signs;
  end
  
  
  function [value] = objective(w)
    value = sum(log(abs(w)));
  end

  function [c, ceq] = constraint(w, sigma)
    c = sqrt(w'*sigma*w)-target_volatility;
    ceq = [];
  end

  function [value] = F(w, sigma,n)
    value = w(:).*(sigma*w(:)) - target_volatility^2/n*ones(n,1);
  end

  function [C_adj] = adjustForSigns(C, signal)
    tmp = repmat(signal,1,size(C,1));
    signs = tmp.*tmp';
    C_adj = C.*signs;
  end

  
end