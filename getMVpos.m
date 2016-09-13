function [MVpos] = getMVpos( signals, corrMat, params )

  [T,N] = size(signals);
  
  MVpos = zeros(T,N);
  for t = 1:T
    Q = (corrMat(:,:,t) + corrMat(:,:,t)')/2; %sym
    activeI = logical(any(Q).*(~isnan(signals(t,:))));
    if ~any(activeI), continue; end 
    [~,PSDflag] = chol(Q(activeI, activeI)); 
    if PSDflag > 0  % will be > 0 if Q is not PSD
      disp('Non PSD cov-matrix')
      [H,D] = eig(Q(activeI, activeI)); D(D<0) = 0; 
      Q(activeI, activeI) = H*D*H'; 
    end
    Q = addToDiag(Q(activeI, activeI), params.lambda);
    MVpos(t,activeI) = Q\(signals(t,activeI)');
  end
  
  
  
  function[pos] = getMVpos_t(Q,activeI,signals)
    pos = nan(1,N); 
    if any(signals)
      pos(activeI) = Q(activeI,activeI)\(signals(activeI)');
    end
  end

  function[regQ] = removeSmallEigDir(Q)
    nD = size(Q,1);
    [H,D] = eig(Q);
    eigs = diag(D);
    toKeep = find(eigs >= mean(eigs));
    regQ = H(:,toKeep)*diag(eigs(toKeep))*H(:,toKeep)';
    regQ(logical(eye(nD))) = diag(Q);
  end

  function[regQ] = addToDiag(Q, lambda)
    regQ = Q + lambda*diag(diag(Q));
  end
    
end

