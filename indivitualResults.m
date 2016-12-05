  function [sharpe, equityCurve, htime, sh_parts] = indivitualResults(pos, cost, Open, Close, sigma_t, riskAdjust)
    if ~exist('riskAdjust','var'), riskAdjust = false; end
    
    nMarkets = size(pos,2);
    htime = holdingTime(pos);
    pos=[nan(1,nMarkets) ; pos(1:end-1,:)];
    
    [~, TRAD, REV] = pos2rev( Open, Close, pos, 'L', Open);
    ret=NansumNan(REV./sigma_t-cost*TRAD,2);
    
    sh_parts = [nanmean(ret), nanstd(ret)];
    sharpe=nanmean(ret)/nanstd(ret)*sqrt(252);
    equityCurve=CumsumNan(ret./nanstd(ret)/sqrt(252)); %% ?
  end