  function [c, ceq] = gTest(x, Q)
    c =  x(:)'*Q*x(:) - 10;
    ceq= [];%(x(:)'.*sign(s)) * Q * (x(:).*sign(s')) - 10;
  end