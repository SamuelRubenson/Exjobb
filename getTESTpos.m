function [pos] = getTESTpos( dZ, signals, corrMat, assetClasses,  target_volatility, lambda )

[T,N] = size(signals);

[dZc, classes] = grpstats(dZ',assetClasses',{'sum','gname'});
dZc = dZc';
Q = estCorrMat(dZc,100,'EMA');
cSignal = grpstats(signals',assetClasses','sum')';

rp_pos = getRPpos(abs(cSignal), Q, target_volatility, 0);


nC = numel(classes);
cInd = nan(nC,N); 
for i = 1:nC
  cInd(i,:) = cellfun(@(c)strcmp(c,classes{i}), assetClasses);
end

pos = nan(T,N);
for t = 1:T
  for iC = 1:nC
    ind = logical(cInd(iC,:).*(~isnan(signals(t,:))));
    n = sum(ind);
    pos(t,ind) = rp_pos(t,iC)/n*ones(1,n);
  end
end
%pos(t,ind) = pos(t,ind)*target_volatility/sqrt(pos(t,ind)*corrMat(ind,ind,t)*pos(t,ind)');

aa = grpstats(pos',assetClasses','sum')';
for t=1:T
ind = ~isnan(aa(t,:));
aa(t,ind).*(Q(ind,ind,t)*aa(t,ind)')'
end


for t=1:T
ind = ~isnan(pos(t,:));
pos(t,ind) = pos(t,ind)*target_volatility/sqrt(pos(t,ind)*corrMat(ind,ind,t)*pos(t,ind)');
end
end