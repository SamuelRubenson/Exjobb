function [y,grady] = quadobj(x,f)
y = f'*x;
if nargout > 1
    grady = f;
end