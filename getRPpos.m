function [ RPpos ] = getRPpos(signals, corrMat, target_volatility)

  [T,N] = size(signals);
  RPpos = nan(T,N);
  
  for t = 2:T
    if mod(t,1000)==0, fprintf('Processing RP-model...(%d/%d)\n',t,T); end
    Q = corrMat(:,:,t);
    activeI = logical(any(Q).*(~isnan(signals(t,:))));
    if ~any(activeI), continue; end
    
    signal = signals(t,activeI)';
    norm_signal = signal/max(abs(signal));
    n = length(signal);
    
    W = []; factor = [];
    for lambda = 0%[1000000 100 10 2 0.5]
      mod_signal = signal;%((Q(activeI,activeI) + lambda*eye(n))/(lambda+1))\signal;
      adjusted_corrMat = adjustForSigns(Q(activeI,activeI),sign(mod_signal(:)));

      w0 = ones(n,1)*0.9*target_volatility/sqrt(sum(sum(adjusted_corrMat)));
      mu = sum(abs(norm_signal))/target_volatility^2/2;
      w_t = rpADMM(w0, adjusted_corrMat, mu, signal/max(abs(signal)));
      if abs(w_t'*adjusted_corrMat*w_t-target_volatility^2)>0.01, disp('sigma error'); disp([w_t'*adjusted_corrMat*w_t, target_volatility^2]); end
      if any(abs(diff(w_t.*(adjusted_corrMat*w_t)./(abs(signal)/max(abs(signal)))))>0.01), disp('not mcr'); disp(w_t.*(adjusted_corrMat*w_t)./(abs(signal)/max(abs(signal)))); end
      scaled_signed_wt = (w_t(:)'/max(abs(w_t))).*(sign(mod_signal(:)'));
      W = [W; scaled_signed_wt]; factor = [factor; max(abs(w_t))];
    end
    dists = pdist2(W,norm_signal(:)');
    [~,closest] = min(dists);
    RPpos(t,activeI) = W(closest,:)* factor(closest);
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

  %[w_t,~,exitflag] = fmincon(@(w)objective(w,adjusted_corrMat,n),w0,[],[],[],[],zeros(n,1),[],[],options);

end