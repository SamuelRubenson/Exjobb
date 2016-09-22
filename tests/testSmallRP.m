clear, clc
load contractsToLoad names
load assetClasses
load 160830
dates = datetime(Date,'ConvertFrom','datenum');
n1 = 65; n2 = 74;
Close = Close(:,n1:n2); Open = Open(:,n1:n2); High = High(:,n1:n2); Low = Low(:,n1:n2); 

N = size(Close,2);
T = numel(dates);
yzv = yangzhang(cat(3,Open,High,Low,Close), 60);
yz = sqrt(yzv([1 1:end-1],:));
dZ = [nan(1,N) ; diff(lvcf(Close))]./yz;
corrMat_t = estCorrMat(dZ, 100, 'EMA');
corrMat = cat(3, corrMat_t(:,:,1), corrMat_t(:,:,1:end-1));

normClose = CumsumNan(dZ);
emaLong = Ema(normClose,1/200);
emaShort = Ema(normClose,1/10);
signals=lvcf(emaShort-emaLong);

%signals = cumsum(randn(T,N)/10);

eigs = [];
testPos = nan(T,N);
testPos2 = nan(T,N);
lambda = 0; target_volatility = 10;
RPpos = nan(T,N);
for t = 6552:6565
  Q = corrMat(:,:,t) + lambda*diag(diag(corrMat(:,:,t)));
  activeI = logical(any(Q).*(~isnan(signals(t,:))));
  if ~any(activeI), continue; end
  [H,D] = eig(Q(activeI,activeI)); %D(1,1) = 0.01;
  %eigs = [eigs, diag(D)];
  Q(activeI,activeI) = H*D*H'; 

  signal = signals(t,activeI)';
  %signal = (H*diag(1./D));
  %test = [test, signal]
  n = length(signal);
  tmp = repmat(sign(signal),1,n);
  signs = tmp.*tmp';
  adjusted_corrMat = Q(activeI,activeI).*signs;
    
  w_t = rpADMM(adjusted_corrMat, target_volatility, signal);
  if abs(w_t'*adjusted_corrMat*w_t-target_volatility^2)>0.01
    disp('sigma error'); disp([w_t'*adjusted_corrMat*w_t, target_volatility^2]); 
  end
%   if any(abs(diff(w_t.*(adjusted_corrMat*w_t)))>0.01)
%     disp('not mcr'); disp(w_t.*(adjusted_corrMat*w_t)); 
%   end
  RPpos(t,activeI) = w_t(:).*sign(signal);
  testPos(t, activeI) = Q(activeI,activeI)\sign(signal);
  testPos(t, activeI) = testPos(t, activeI) + 2*sign(testPos(t, activeI));
  %testPos2(t, activeI) = Q(activeI,activeI)\ones(size(signal));
  [H(:,1), sign(signals(t,activeI)')-sign(signals(t-1,activeI)'), RPpos(t,activeI)' - RPpos(t-1,activeI)', sign(RPpos(t,activeI)')]
end

figure(1), clf, plot(RPpos)
figure(2), clf, plot(testPos)
%figure(3), clf, plot(testPos2)
%[H(:,1), sign(signals(8846,:)')-sign(signals(8847,:)'), RPpos(8846,:)' - RPpos(8847,:)']

%%

lambda = 10;
minEig = nan(size(Q,3),74);
for t = 1:size(Q,3)
  Qt = Q(:,:,t);
  activeI = logical(any(Qt));
  if ~any(activeI), continue; end
  minEig(t,activeI) = eig(( Qt(activeI,activeI) + lambda*diag(diag(Qt(activeI,activeI))))/(1+lambda));
end
figure()
plot(minEig)