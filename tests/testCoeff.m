x = [1; zeros(1000,1)];
a = 1-1/120;
y1 = filter(1-a,[1, -a],x);
y2 = filter(1-a,[1, -a],filter(1-a,[1, -a],x));
plot([y1 y2 (y1 + y2)/2])

%%
yzv=yangzhang(cat(3,Open,High,Low,Close), Config.yz_tau);
yz = sqrt(yzv([1 1:end-1],:));
dZ = [nan(1,size(Close,2)) ; diff(lvcf(Close))]./yz;
corrMat_t = estCorrMat(dZ, 100, 'EMA'); %has paramters
%corrMat_tm1 = cat(3, corrMat_t(:,:,1), corrMat_t(:,:,1:end-1));
figure(1), hold on
plot(squeeze(corrMat_t(36,19,:)))
corrMat_t = estCorrMat(dZ, 100, 'dEMA');
plot(squeeze(corrMat_t(36,19,:)))
corrMat_t = estCorrMat(dZ, 100, 'avgEMA');
plot(squeeze(corrMat_t(36,19,:)))