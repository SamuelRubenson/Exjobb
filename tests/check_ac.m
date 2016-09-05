function [ ] = check_ac(Open,High,Low,Close)

yzv=yangzhang(cat(3,Open,High,Low,Close));
yz = sqrt(yzv([1 1:end-1],:));
dC = [nan(1,size(Close,2)) ; diff(lvcf(Close))]./yz;

tau = 500; a=1-1/tau; 
coeff = @(s)(1-a)*a.^(s);
lag = 1000;
[x_corr,lags] = xcorr(dC(4000:end,36),dC(4000:end,37),1000);
figure(), hold on
plot(lags,x_corr)
%plot(1:lag,autoc(2:end),1:lag, coeff(1:lag))


end

