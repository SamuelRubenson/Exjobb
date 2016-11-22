function [MVpos] = getMVpos( signals, corrMat, target_volatility, lambda, assetClasses )

  [T,N] = size(signals);
  
  lambda2 = 0;
  classes = unique(assetClasses);
  nC = numel(classes);
  cInd = nan(nC,N); 
  for i = 1:nC
    cInd(i,:) = cellfun(@(c)strcmp(c,classes{i}), assetClasses);
  end
  
  MVpos = nan(T,N);
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
    Qreg = addToDiag(Q(activeI, activeI), lambda);
    s = signals(t,activeI)';
    C = cInd(:,activeI);
    classMeans = C*s;
    L = nan(sum(activeI),1);
    for i = 1:size(C,1), L(logical(C(i,:))) = classMeans(i); end
    S = (1-lambda2)*s + lambda2*L;
    wt = Qreg\S;
    wt_scaled = wt*target_volatility/sqrt(wt(:)'*Q(activeI, activeI)*wt(:));
    MVpos(t,activeI) = wt_scaled;
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

