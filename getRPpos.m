function [ RPpos ] = getRPpos(signals, corrMat, target_volatility)

  [T,N] = size(signals);
 
  RPpos = nan(T,N);
  
  for t = 2:T
    Q = (corrMat(:,:,t)+ corrMat(:,:,t)')/2;
    if mod(t,1000)==0, disp(t); end
    activeI = logical(any(Q).*(~isnan(signals(t,:))));
    if ~any(activeI), continue; end
    w0 = sign(signals(t,activeI)');
    Q(activeI,activeI) = test(Q(activeI,activeI),w0);
    n = length(w0);
    fmin_options = optimset('Display', 'off');
%     options = optimoptions(@fmincon,'MaxIter',2000,'Display','off');
%     [w_t, ~, exitflag] = fmincon(@(w)-objective(w),w0,[],[],[],[],lb,ub,...
%       @(w)constraint(w,Q(activeI,activeI)),options);
    [w_t,~,exitflag] = fsolve(@(w)F(w,Q(activeI,activeI),n),abs(w0),fmin_options);
    if exitflag < 1
      fprintf('RP: fmincon failed to find optimum, extitflag: %d \n', exitflag)
    end
%     [w_tt, w_t]
    RPpos(t,activeI) = abs(w_t).*w0;
%     if sum((w_t.*w0)<0)>0, disp('changed sign'); disp(t); end
  end
  
  
  function [value] = objective(w)
    value = sum(log(abs(w)));
  end

  function [c, ceq] = constraint(w, sigma)
    c = sqrt(w'*sigma*w)-target_volatility;
    ceq = [];
  end

  function [value] = F(w, sigma,n)
    value = w(:).*(sigma*w(:)) - target_volatility^2/n*ones(n,1);
  end

  function [mat] = test(mat, signal)
    for i = 1:size(mat,1)
      for j = 1:size(mat,2)
        mat(i,j) = mat(i,j)*sign(signal(i)*signal(j));
      end
    end
  end

  
end