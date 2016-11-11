alpha = [-0.75, -0.5, -0.25, -0.1, 0, 0.1,];
x = linspace(-0.5,1);
y = zeros(size(x));
for i = 1:numel(alpha)
  y = y - min(0, x+alpha(i))/i;
end
figure(), plot(x,y)
hold on, plot(x, (-min(0,(x+alpha(1)))).^(3/2))

%%
clc
%pos = outCome.Models.LES.pos;

testPos1 = pos;
testPos2 = pos;
testPos3 = pos;

n=3;
for i = 1:n
  testPos1 = [nan(1,74); (testPos1(1:end-1,:) + testPos1(2:end,:))/2];
end
n = n+1;
for t = n:size(pos,1)
  testPos2(t,:) = nanmean(pos(t-n+1:t,:),1);
end


for t = 2:size(pos,1)
  ind = ~isnan(testPos3(t-1,:));
  testPos3(t,ind) = (1-1/n)*testPos3(t-1,ind) + 1/n*testPos3(t,ind);
end
 
  
  
[sh, ~, ht, ~] = indivitualResults(testPos1, 0, Open, Close, outCome.General.std, false)
[sh, ~, ht, ~] = indivitualResults(testPos2, 0, Open, Close, outCome.General.std, false)
[sh, eq, ht, ~] = indivitualResults(testPos3, 0, Open, Close, outCome.General.std, false);
nanmean(eq-cummax(eq)), sh, ht


figure(), plot(outCome.Models.LES.equityCurve), hold on, plot(eq)