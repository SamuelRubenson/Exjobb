f=@(x,y) log(abs(x.*y));
a = 5;
x = linspace(-a,a); y = linspace(-a,a);
sigma = [1 -0.8; 0.2 1]; target = 10;
val = valid(x,y,sigma,target);
[X,Y] = meshgrid(x,y);
Z = f(X,Y);
figure(), hold on
surf(X,Y,Z)
surf(X,Y,10*val)
xlabel('x')
ylabel('y')


