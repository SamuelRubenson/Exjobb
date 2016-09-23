function [ RPpos ] = getRPpos(signals, corrMat, target_volatility, lambda, regCoeffs)
  if ~exist('lambda', 'var'), lambda = 0; end
  if ~exist('regCoeffs', 'var'), regCoeffs = 10^10; end
  [T,N] = size(signals);
  RPpos = nan(T,N);

  for t = 2:T
    if mod(t,1000)==0, fprintf('Processing RP-model...(%d/%d)\n',t,T); end
    Q = addToDiag(corrMat(:,:,t), lambda);
    activeI = logical(any(Q).*(~isnan(signals(t,:))));
    if ~any(activeI), continue; end
    
    signal = signals(t,activeI)';
    norm_signal = signal/norm(signal);
    n = length(signal);
    
    W = []; factor = [];
    for iReg = regCoeffs
      mod_signal = ((Q(activeI,activeI) + iReg*eye(n))/(iReg+1))\signal;
      adjusted_corrMat = adjustForSigns(Q(activeI,activeI),sign(mod_signal(:)));
      w_t = rpADMM(adjusted_corrMat, target_volatility);
      checkSolution(w_t, adjusted_corrMat)
      scaled_signed_wt = (w_t(:)'/norm(w_t)).*(sign(mod_signal(:)'));
      W = [W; scaled_signed_wt]; factor = [factor; norm(w_t)];
    end
    dists = pdist2(W,norm_signal(:)');
    [~,closest] = min(dists);
    w = W(closest,:)*factor(closest);
    RPpos(t,activeI) = w*target_volatility/sqrt(w(:)'*corrMat(activeI,activeI,t)*w(:));
  end
  
  
  
  function [C_adj] = adjustForSigns(C, signal)
    tmp = repmat(signal,1,size(C,1));
    signs = tmp.*tmp';
    C_adj = C.*signs;
  end

  function [] = checkSolution(w_t, adjusted_corrMat)
    if abs(w_t'*adjusted_corrMat*w_t-target_volatility^2)>0.01
      disp('sigma error'); disp([w_t'*adjusted_corrMat*w_t, target_volatility^2]); 
    end
    if any(abs(diff(w_t.*(adjusted_corrMat*w_t)))>0.01)
      disp('not mcr'); disp(w_t.*(adjusted_corrMat*w_t)); 
    end
  end

  function[regQ] = addToDiag(Q, lambda)
    regQ = Q + lambda*diag(diag(Q));
  end

end