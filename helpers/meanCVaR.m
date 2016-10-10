function [ out ] = meanCVaR( rev, beta )
q = 1-beta;
ind = ~isnan(rev);
N = sum(ind);
cut = floor(q*N);
srted = sort(rev(ind));
out = mean(srted(1:cut));
end

