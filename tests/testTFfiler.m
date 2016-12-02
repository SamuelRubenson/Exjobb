dZ = [1; zeros(499,1)];
[T,N] = size(dZ);
aLong = 200; aShort = 10;
normClose = CumsumNan(dZ);
emaLong = Ema(normClose,1/aLong);
emaShort = Ema(normClose,1/aShort);
pos=lvcf(emaShort-emaLong);
figure(22),hold on, xlabel('s'), ylabel('c_s'), plot(pos/sum(pos)), legend('\tau = 125')


%%
q = 500;
x = [1; zeros(q-1,1)];
a = 1-1/130; a2 = 1-1/10;
y1 = filter(1-a,[1, -a],x); y2 = filter(1-a2,[1, -a2],x);
y3 = cumsum(y2)-cumsum(y1); y3 = y3/sum(y3);
sum((1:q)'.*y3)
%y2 = filter(1-a,[1, -a],filter(1-a,[1, -a],x));
%y3 = (y1 + 1.5*y2)/2;
figure(20), plot(y3)