function hess = quadhess(x,lambda,H)
hess = lambda.ineqnonlin(end)*H;