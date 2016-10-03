function [pos] = getMVRPpos( signals, corrMat, assetClasses,  target_volatility, lambdaMV, lambdaRP )

  [T,N] = size(signals);

  classes = unique(assetClasses);
  nC = numel(classes);
  cInd = nan(nC,N); 
  for i = 1:nC
    cInd(i,:) = cellfun(@(c)strcmp(c,classes{i}), assetClasses);
  end

  
 mv_pos = {}; mu = nan(T,nC);
 for iC = 1:nC
   ind = logical(cInd(iC,:));
   mv_pos{iC} = getMVpos(signals(:,ind),corrMat(ind,ind,:),target_volatility,lambdaMV);
   mu(:,iC) = NansumNan(mv_pos{iC}.*signals(:,ind),2);
 end
 
 corrMatClass = nan(nC,nC,T);
 for iC = 1:nC
   gamma_i = mv_pos{iC};
   iInd = logical(cInd(iC,:));
   for jC = 1:nC
     jInd = logical(cInd(jC,:));
     gamma_j = mv_pos{jC};
     for t = 1:T
       Qt = corrMat(iInd,jInd,t);
       activeI = logical(any(Qt,2)'.*(~isnan(gamma_i(t,:)))); 
       activeJ = logical(any(Qt,1).*(~isnan(gamma_j(t,:))));
       if ~any(activeI) || ~any(activeJ), continue; end
       corrMatClass(iC,jC,t) = gamma_i(t,activeI)*Qt(activeI,activeJ)*gamma_j(t,activeJ)'/target_volatility^2;
     end
   end
 end

 
 rp_pos = getRPpos(mu,corrMatClass, target_volatility, lambdaRP);
 
 pos = nan(T,N);
 for iC = 1:nC
   ind = logical(cInd(iC,:));
   gamma = mv_pos{iC};
   n = size(gamma,2);
   pos(:,ind) = repmat(rp_pos(:,iC),1,n).*gamma/target_volatility;
 end
 
 
end