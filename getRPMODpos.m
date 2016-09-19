function [ RPpos ] = getRPMODpos(signals, corrMat, target_volatility, lambda)
  if ~exist('lambda', 'var'), lambda = 0; end
  [T,N] = size(signals);
  RPpos = nan(T,N);
  
  for t = 2:T
    if mod(t,1000)==0, fprintf('Processing RPmod-model...(%d/%d)\n',t,T); end
    Q = addToDiag(corrMat(:,:,t), lambda);
    activeI = logical(any(Q).*(~isnan(signals(t,:))));
    if ~any(activeI), continue; end
    
    signal = signals(t,activeI)';
    
    adjusted_corrMat = adjustForSigns(Q(activeI,activeI),sign(signal(:)));

    w0 = ones(size(signal))*0.9*target_volatility/sqrt(sum(sum(adjusted_corrMat)));
    mu = sum(abs(signal))/target_volatility^2/2;
    w_t = rpADMM(w0, adjusted_corrMat, mu, signal);
    checkSolution(w_t, adjusted_corrMat, signal);
   
    RPpos(t,activeI) = w_t.*sign(signal);
  end
  
  
  
  function [C_adj] = adjustForSigns(C, signal)
    tmp = repmat(signal,1,size(C,1));
    signs = tmp.*tmp';
    C_adj = C.*signs;
  end

  function [] = checkSolution(w_t, adjusted_corrMat, signal)
    if abs(w_t'*adjusted_corrMat*w_t-target_volatility^2)>0.01
      disp('sigma error'); disp([w_t'*adjusted_corrMat*w_t, target_volatility^2]); 
    end
    if any(abs(diff(w_t.*(adjusted_corrMat*w_t)./(abs(signal))))>0.01)
      disp('not mcr'); disp(w_t.*(adjusted_corrMat*w_t)./(abs(signal))); 
    end
  end

  function[regQ] = addToDiag(Q, lambda)
    regQ = Q + lambda*diag(diag(Q));
  end

end