  function [f, g] = objTest(Y, x)
    f = norm(Y*x,2);
    g = Y'*Y*x;
  end