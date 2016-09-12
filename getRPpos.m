function [ RPpos ] = getRPpos(signals, corrMat, target_volatility)

  [T,N] = size(signals);
  RPpos = nan(T,N);
  options = optimoptions('fmincon', 'GradObj','on', 'Display','off');
  
  for t = 2:T
    if mod(t,1000)==0, fprintf('Processing RP-model...(%d/%d)\n',t,T); end
    Q = corrMat(:,:,t);
    activeI = logical(any(Q).*(~isnan(signals(t,:))));
    if ~any(activeI), continue; end
    
    signal = signals(t,activeI)';
    norm_signal = signal/max(abs(signal));
    %signal_signs = sign(signal);
    n = length(signal);
    
    W = []; factor = [];
    for lambda = [1000000 100 10 2 0.5]
      mod_signal = ((Q(activeI,activeI) + lambda*eye(n))/(lambda+1))\signal;
      mod_signal(mod_signal==0) = 1;
      adjusted_corrMat = adjustForSigns(Q(activeI,activeI),sign(mod_signal(:)));

      w0 = ones(n,1);% 0.99*target_volatility/sqrt(sum(sum(adjusted_corrMat)))*signal_signs; 
      [w_t,~,exitflag] = fmincon(@(w)objective(w,adjusted_corrMat,n),w0,[],[],[],[],zeros(n,1),[],[],options);
      scaled_signed_wt = (w_t(:)'/max(abs(w_t))).*(sign(mod_signal(:)'));
      W = [W; scaled_signed_wt]; factor = [factor; max(abs(w_t))];
      if exitflag<1, disp('fail'); disp(exitflag); end
    end
    %w_t = RP_newton(w0,adjusted_corrMat,target_volatility);
    dists = pdist2(W,norm_signal(:)');%@(x1,x2)exp(-pdist2(x1,x2)/0.5));
    [~,closest] = min(dists);
    w_best = W(closest,:); mult = factor(closest);
    RPpos(t,activeI) = w_best*mult;
    disp([t, closest])
  end
  
  
  function [f,g] = objective(w,Q,n)
    f = -sum(log(w)) + n/target_volatility^2/2*(w'*Q*w);
    g = -1./w + n/target_volatility^2*(Q*w);
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