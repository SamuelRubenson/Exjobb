function [ new_pos ] = avgPos( pos, tau )
if ~exist('tau', 'var'), tau = 4; end

new_pos = pos;
for t = 2:size(pos,1)
  ind = ~isnan(new_pos(t-1,:));
  new_pos(t,ind) = (1-1/tau)*new_pos(t-1,ind) + 1/tau*new_pos(t,ind);
end

end