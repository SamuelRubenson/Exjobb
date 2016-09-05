function y = NansumNan(x,dim)
if nargin == 1 
    idx = all(isnan(x));
    x(isnan(x)) = 0;
    y = sum(x);
    y(idx) = nan;
else           
    idx = all(isnan(x), dim);
    x(isnan(x)) = 0;
    y = sum(x, dim);
    y(idx) = nan;
end
