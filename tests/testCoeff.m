q = 252;
x = [1; zeros(q-1,1)];
a = 1-2/q; a2 = 1-10/q;
y1 = filter(1-a,[1, -a],x); 
y2 = filter(1-a,[1, -a],filter(1-a,[1, -a],x));
y3 = (y1 + 1.5*y2)/2;
y4 = -linspace(-q/3,q-q/3,q)'.^2/max(linspace(-q/3,q-q/3,q)'.^2)+1;
y5 = flip((1:q)'/q);
figure(20), plot([y1/max(y1) y2/max(y2) y3/max(y3), flip((1:q)'/q) ])
%figure(21), plot([y5 (y4+y5)/2 y4])
%%

q = 1000;
x = [1; zeros(q-1,1)];
a = 1-1/25; a2 = 1-1/10;
y1 = filter(1-a,[1, -a],x); y2 = filter(1-a2,[1, -a2],x);
y3 = cumsum(y2)-cumsum(y1); y3 = y3/sum(y3);
sum((1:q)'.*y3)
%y2 = filter(1-a,[1, -a],filter(1-a,[1, -a],x));
%y3 = (y1 + 1.5*y2)/2;
figure(20), plot(y3)




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