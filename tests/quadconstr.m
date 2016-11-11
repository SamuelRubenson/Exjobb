function [y,yeq,grady,gradyeq] = quadconstr(x,H,A,b,lambda)
jj = size(A,1) + 1; % jj is the number of inequality constraints
y = zeros(1,jj);
y(1:jj-1) = A*x-b;
y(end) = x'*H*x - lambda;
yeq = [];

if nargout > 2
    grady = zeros(length(x),jj);
    grady(:,1:end-1) = A';
    grady(:,end) = 2*H*x;
end
gradyeq = [];