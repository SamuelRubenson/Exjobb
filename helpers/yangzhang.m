function V = yangzhang(P,tau,imputefirst,geomPrices,firstNightZero,smoothStart,removeMeanGeom)
%YANGZHANG  Yang Zhang volatility
%   V = YANGZHANG(P,tau, imputefirst, geomPrices, firstNightZero) computes
%   a rolling estimate of the variance according to the Yang Zhang method.
%   The 3-dimensional price vector P must have the third dimension populated
%   with open, high, low, and closing prices in that order.
%
%   Formulas used, from "Trendmodeller, Stylized facts" by Jesper Sandin:
%
%   YZ_t = (O_t-C_(t-1))^2 + 0.5(H_t-L_t)^2 - (2ln2-1)*(O_t-C_t)^2
%
%   v_t = a * v_(t-1) + (1-a) * YZ_t
%
%   Here a = 1 - 1/tau. tau is a time constant.
%   If not provided, it defaults to 60.
%
%   2012 Per Hallberg
%   2013 "imputefirst" option added by Tobias Rydén
%   2014 geomPrices funcionality (non-causal) added by someone 
%   2015 firstNightZero funcionality added by Per Hallberg
%   2015-09-01 smoothStart functionality added by Tobias Rydén
%   2015-09-17 Fall-back on close-close volatility, by Tobias R

if ~exist('firstNightZero','var') || isempty(firstNightZero), firstNightZero = true; end

if ~exist('geomPrices','var') || isempty(geomPrices), geomPrices = false; end

if ~exist('removeMeanGeom','var') || isempty(removeMeanGeom), removeMeanGeom = true; end

if ~exist('tau','var') || isempty(tau), tau = 60; end

if ~exist('imputefirst','var') || isempty(imputefirst), imputefirst = true; end

if ~exist('imputefirst','var') || isempty(imputefirst), imputefirst = true; end

if ~exist('smoothStart','var') || isempty(smoothStart), smoothStart = false; end

% Check if dates are the first or second dimension. We assume the
% number of dates is larger than the number of markets. We also assume
% the different prices (open, high, etc.) are the third dimension.

% if size(P,1) < size(P,2)
%     P = permute(P, [2 1 3]);
% end

D = size(P,1);
N = size(P,2);
a = 1/tau;

% To deal with the situation where we have only one market
if ndims(P) < 3
    P = reshape(P, [D 1 N]);
    N = 1;
end


V = NaN(D,N);   % Rolling Yang Zhang variance estimates

for k=1:N

    % Compute YZ estimates
    
    if geomPrices
        idx = all(~isnan(P(:,k,:)),3);  % indices with all prices
        if ~any(idx), continue, end
        
        Op = P(idx,k,1);
        Hi = P(idx,k,2);
        Lo = P(idx,k,3);
        Cl = P(idx,k,4);
        n = sum(idx);
        
        cl_op = [0; log(Op(2:end)./Cl(1:end-1))];
        op_cl = [0; log(Op(2:end)./Cl(1:end-1))];
        if removeMeanGeom
            V_o = (cl_op - mean(cl_op)).^2;
            V_c = (op_cl - mean(op_cl)).^2;
        else
            V_o = cl_op.^2;
            V_c = op_cl.^2;
        end
        V_rs = log(Hi./Cl).*log(Hi./Op) + log(Lo./Cl).*log(Lo./Op);
        c = 0.34 / (1 + (n+1)/(n-1));
        YZ = V_o + c*V_c + (1-c)*V_rs;
    else
        idx = ~isnan(P(:,k,4));  % indices with closing prices
        if ~any(idx), continue, end
        
        Op = P(idx,k,1);
        Hi = P(idx,k,2);
        Lo = P(idx,k,3);
        Cl = P(idx,k,4);
        YZ = 0.5* (Hi-Lo).^2 - (2*log(2)-1)*(Op-Cl).^2;
        YZ(2:end) = YZ(2:end) + (Op(2:end)-Cl(1:end-1)).^2;
        
        % Fall-back on close-close volatility for days with no
        % open/high/low prices
        ClCl2 = [NaN; diff(Cl)].^2;
        YZ(isnan(YZ)) = ClCl2(isnan(YZ));
        
        % Quick and dirty for possible case that YZ(1) is NaN; happens when
        % no open/high/low for first day
        if isnan(YZ(1)), YZ(1) = YZ(2); end
    end
    
    if firstNightZero
        if ~smoothStart
            initVal = YZ(1);
        else
            initVal = mean(YZ(1:min(ceil(tau),numel(YZ))));
        end
        V(idx,k) = filter(a,[1 ; -(1-a)],YZ, (1-a)*initVal);
    else
        if ~smoothStart
            initVal = YZ(2);
        else
            initVal = mean(YZ(2:min(ceil(tau)+1,numel(YZ))));
        end
        V(idx,k) = [nan; filter(a,[1 ; -(1-a)],YZ(2:end), (1-a)*initVal)];
    end
    
    if imputefirst
        % impute possible leading zeros with first non-zero value
        i = find(V(:,k)>0,1,'first');
        idx = V(1:i,k)==0; % only indices prior to i; there should actually be no after
        V(idx,k) = V(i,k);
    end
    
    % fill whole vector, last value carry forward
    for i=2:D, if isnan(V(i,k)), V(i,k) = V(i-1,k); end, end
    
end

end
