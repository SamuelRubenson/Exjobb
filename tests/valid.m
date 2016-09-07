function [ out ] = valid( x,y, sigma,target )
out = zeros(length(x),length(y));
for ix = 1:length(x)
  for iy = 1:length(y)
    out(ix,iy) = [x(ix) y(iy)]*sigma*[x(ix); y(iy)] <= target;
  end
end
out(out==0) = nan;
end

