function [ RPpos ] = getRPpos(signals, corrMat, target_volatility)

  [T,N] = size(signals);
 
  RPpos = nan(T,N);
  
  for t = 2:T
    if mod(t,1000)==0, fprintf('Processing RP-model...(%d/%d)\n',t,T); end
    Q = corrMat(:,:,t);
    activeI = logical(any(Q).*(~isnan(signals(t,:))));
    if ~any(activeI), continue; end
    
    signal_signs = sign(signals(t,activeI)');
    adjusted_corrMat = adjustForSigns(Q(activeI,activeI),signal_signs);
    %w0 = 0.99*target_volatility/sqrt(sum(sum(adjusted_corrMat)))*ones(length(signal_signs),1);
    n = length(signal_signs);
    w0 = abs(signal_signs);% 0.99*target_volatility/sqrt(sum(sum(adjusted_corrMat)))*signal_signs; 
    
    options = optimoptions('fmincon', 'GradObj','on', 'Display','off');
    [w_t,~,exitflag] = fmincon(@(w)objective(w,adjusted_corrMat,n),w0,[],[],[],[],zeros(n,1),[],[],options);

%     warning('off', 'optim:fminunc:SwitchingMethod'); 
%     [w_t,~,exitflag] = fminunc(@(w)-sum(log(w)) + n/target_volatility^2*(w'*adjusted_corrMat*w - target_volatility^2),...
%       w0,optimset('Display','off'));
    % [w_t,~,exitflag] = fsolve(@(w)F(w,Q(activeI,activeI),n),signal_signs,optimset('Display','off')); 
    
    %w_t = RP_newton(w0,adjusted_corrMat,target_volatility);
    
    
    %if any(sign(w_t)~=sign(w0)), disp('signChange'); end
    if exitflag<1, disp('fail'); disp(exitflag); end
    RPpos(t,activeI) = w_t(:).*signal_signs;
  end
  
  
  function [f,g] = objective(w,Q,n)
    f = -sum(log(w)) + n/target_volatility^2*(w'*Q*w);
    g = -1./w + 2*n/target_volatility^2*(Q*w);
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