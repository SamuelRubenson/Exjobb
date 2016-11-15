function [ RPpos ] = getRPMODpos(signals, corrMat, target_volatility, lambda, regCoeffs)
  if ~exist('lambda', 'var'), lambda = 0; end
  if ~exist('regCoeff', 'var'), regCoeffs = 10^10; end
  [T,N] = size(signals);
  RPpos = nan(T,N);
  
  for t = 2:T
    if mod(t,1000)==0, fprintf('Processing RPmod-model...(%d/%d)\n',t,T); end
    Q = addToDiag(corrMat(:,:,t), lambda);
    activeI = logical(any(Q).*(~isnan(signals(t,:))));
    if ~any(activeI), continue; end
    signal = signals(t,activeI)';


    w_init = RP_ADMM(Q(activeI, activeI), signal, target_volatility, 'RPmod');
    expRet_init = signal'*w_init;
    w = iterateSigns(Q(activeI,activeI), signal, w_init, expRet_init, signal);

    RPpos(t,activeI) = w*target_volatility/sqrt(w(:)'*corrMat(activeI,activeI,t)*w(:));
  end
  
  
  function [w_best] = iterateSigns(Q, signal, w_best, expRet_best, signal_current)
    for iS = 1:length(signal)
      mod_signal = signal_current;
      mod_signal(iS) = -signal_current(iS);
      w_new = RP_ADMM(Q, mod_signal, target_volatility, 'RPmod');
      expRet = signal'*w_new;
      if expRet > expRet_best
        w_best = iterateSigns(Q, signal, w_new, expRet, mod_signal);
        break
      end
    end
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