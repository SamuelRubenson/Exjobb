  function [sharpe, equityCurve, htime, ret, sharpeParts] = indivitualResults(pos, cost, Open, Close, sigma_t, riskAdjust)
    if ~exist('riskAdjust','var'), riskAdjust = false; end
    
    nMarkets = size(pos,2);
    htime = holdingTime(pos);
    pos=[nan(1,nMarkets) ; pos(1:end-1,:)];
    if riskAdjust
      pos = pos./repmat(NansumNan(abs(pos),2),1,nMarkets);
    end
    [~, TRAD, REV] = pos2rev( Open, Close, pos, 'L', Open);
    ret=NansumNan(REV./sigma_t-cost*TRAD,2);
    
    sharpe=nanmean(ret)/nanstd(ret)*sqrt(252);
    sharpeParts = [nanmean(ret), nanstd(ret)];
    equityCurve=CumsumNan(ret./nanstd(ret)/sqrt(252)); %% ?
  end