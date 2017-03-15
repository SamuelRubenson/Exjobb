function [ f ] = EvaluateIndividual(x, Q, signal)

 signs = sign(x-0.5);
 s = abs(signal).*signs;
 w = RP_ADMM(Q, 1, s, 'RPmod');
 w2 = w/(w'*Q*w);
 
 f = signal*w2;

end
