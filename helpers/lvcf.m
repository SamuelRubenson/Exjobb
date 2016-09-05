function Y = lvcf(X,d)
if exist('d', 'var')
    Y = lvcfNd(X,d);
else
    nCols = size(X,2);
    Y = nan(size(X));
    for c = 1:nCols
        okIdx = ~isnan(X(:,c));
        cumIdx = cumsum(okIdx);
        cumIdx(cumIdx==0) = [];
        Xnonan = X(okIdx,c);
        Y(end-numel(cumIdx)+1:end,c) = Xnonan(cumIdx);
    end
end