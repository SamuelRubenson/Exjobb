function y = CumsumNan(x,dim)
idx = isnan(x);
x(idx) = 0;
if nargin == 1 
    y = cumsum(x);
else           
    y = cumsum(x, dim);
end
y(idx) = nan;
