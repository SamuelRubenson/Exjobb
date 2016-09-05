function [corrMatEst] = estCorrMat(dZ, tau, Filter)
  
  if ~exist('tau', 'var') || isempty(tau), tau = 100; end
  if ~exist('Filter', 'var') || isempty(Filter), Filter = 'EMA'; end
  burnIn = floor(tau*log(4));
  
  [T, N] = size(dZ);
  a = 1 - 1/tau;
  
  point_ests = nan(N,N,T);
  for t = 2:T
    point_ests(:,:,t) = dZ(t,:)'*dZ(t,:);
  end
  
  switch Filter
    case 'EMA'
      covMatEst = emaFilter(point_ests);
    case 'dEMA'
      covMatEst = emaFilter(emaFilter(point_ests));
    case 'avgEMA'      
      y1 = emaFilter(point_ests);
      y2 = emaFilter(y1);
      covMatEst = (y1+y2)/2;
    otherwise
      disp('Unknown filter')
      return
  end
  
  corrMatEst = normalize(covMatEst);
  corrMatEst = removeBurnInPeriod(corrMatEst);
  %Sigma_hat = cat(3, corrMatEst(:,:,1), corrMatEst(:,:,1:end-1));

  %---------------------------------------------------------------------
  
  
  function [rolling_est] = emaFilter(point_ests)
    rolling_est = nan(size(point_ests));
    for it = 2:T
      Y_t = point_ests(:,:,it);
      C_t = a*rolling_est(:,:,it-1) + (1-a)*Y_t;

      idx_new = isnan(Y_t);
      idx_prev = isnan(rolling_est(:,:,it-1));
      only_new = logical((~idx_new).*idx_prev); 
      C_t(only_new) = (1-a)*Y_t(only_new);

      rolling_est(:,:,it) = C_t;
    end
  end
    

  function [C_norm] = normalize(C)
    C_norm = nan(size(C));
    for it = 2:T
      variances = repmat(diag(C(:,:,it)),1,N);
      norm_mat = sqrt(variances'.*variances);
      C_norm(:,:,it) = C(:,:,it)./norm_mat;
    end
  end


  function [covariance] = removeBurnInPeriod(covariance)
    start_index = arrayfun(@(k) find(~isnan(covariance(k,k,:)),1,'first'),1:N);
    for iN = 1:N
      %variance(start_index(iN):start_index(iN)+burnIn-1,iN) = nan(burnIn,1);
      for it = start_index(iN):start_index(iN)+burnIn-1
        covariance(iN,:,it) = nan(1,N);
        covariance(:,iN,it) = nan(N,1);
      end
    end
  end


end