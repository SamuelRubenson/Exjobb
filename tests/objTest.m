  function [f, g] = objTest(Y, x)
    f = norm(min(0,Y*x),2);
    Y2 = Y(Y*x<0,:);
    g = (Y2'*Y2*x);
  end