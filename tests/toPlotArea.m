f=@(x,y) log(abs(x.*y));
a = 5;
x = linspace(-a,a,80); y = linspace(-a,a,80);
sigma = [1 0.5; 0.5 1]; target = 10;
val = valid(x,y,sigma,target);
[X,Y] = meshgrid(x,y);
Z = f(X,Y);
C = Z;
C(~isnan(val)) = 10;
figure(), hold on
surf(X,Y,Z,C)
%surf(X,Y,10*val)
xlabel('w_1')
ylabel('w_2')
zlabel('f(w)')


