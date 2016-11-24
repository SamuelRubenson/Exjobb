function [w_best] = iterateSigns(Q, signal, w_best, expRet_best, signal_in)
    nS = length(signal);
    sort_s = sort(abs(signal_in)); threch = sort_s(max(1,floor(0.33*nS))); 
    signal_out = signal_in;
    for iS = 1:nS
      if abs(signal_in(iS))>threch, continue; end
      mod_signal = signal_in;
      mod_signal(iS) = -signal_in(iS);
      w_new = RP_ADMM(Q, 10, mod_signal, 'RPmod');
      expRet = signal'*w_new;
      if expRet > expRet_best
        expRet_best = expRet;
        w_best = w_new; 
        signal_out = mod_signal;
      end
    end
    if any(signal_out ~= signal_in)
      disp('changed')
      w_best = iterateSigns(Q, signal, w_best, expRet_best, signal_out);
    end
end