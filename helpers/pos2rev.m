function [ POS, TRAD, REV, REVLO, REVSO, TRADLO, TRADSO ] = ...
    pos2rev( Popen, Pclose, dPos, tradeTime, Pmid, marketIdx)
%POS2REV Preperation before stratEvaluator
%   [POS, TRAD, REV, REVLO, REVSO, TRADLO, TRADSO] = ...
%         POS2REV( Popen, Pclose, dPos, tradeTime, [Pmid], [marketIdx])
%   generates matrices used by stratEvaluator. Here dPos is a matrix of
%   desired daily positions, with size equal to that of Popen. The
%   variable tradeTime takes one of the following values:
%   'C' - trade on closing prices
%   'L' - trade on levels. Provide price levels in matrix Pmid.
%   'nO' - trade on the next opening price
%   'nC' - trade on the next closing price (the following trading day)
%   'euC' - trade Europe and US on close, but Asia on next open.
%   'uC' - trade US on close, but Asia and Europe on next open.
%   'euM' - trade Europe and US on mid, but Asia on next open.
%   'uM' - trade Europe on close, US on mid, and Asia on next open.
%
%   The last two alternatives for tradeTime ('euM' and 'uM') require the
%   optional argument Pmid to be populated with midday prices.
%
%   The tradeTime='L' option requires Pmid to be populated with the level
%   prices on days where the position changes. The rest must be NaN.
%
%   To handle closed days properly, make sure the dPos matrix or at least
%   one of Popen and Pclose has NaN on days where the market in
%   question is closed. The POS matrix returned will have NaN on days when
%   the market i closed.
%
%   Examples:
%   1) POS is the output from a strategy with actual end-of-day positions
%   where positions are determined the day before:
%   [~, TRAD, REV] = ...
%       pos2rev(Popen, Pclose, POS([2:end end],:), 'nO');
%
%   2) POS is the end-of-day positions from a model that only trades on
%   levels. Those levels are given in Plevel. 
%   [~, TRAD, REV, REVLO, REVSO, TRADLO, TRADSO] = ...
%       pos2rev(Popen, Pclose, POS, 'L', Plevel);
%
%   Per Hallberg, 2012
%   
%   2013-01-08: Corrected a bug when strategy wanted to change desired
%               position on a closed day.
%   2013-06-27: Added functionality for trading on levels, tradeTime = 'L'
%
%   2013-10-10: Added output variables TRADLO and TRADSO.
%
%   2014-02-07: Modified to a much quicker version.

[nDates,nInstr] = size(Popen);

% If tradeTime contains 'u' somewhere then the behavior depends on the
% tradeZone. Read that info from mat-file "tradeZone".
if any(lower(tradeTime)=='u')
    load tradeZone;
    if nargin > 5
        tradeZone = tradeZone(marketIdx); %#ok
    end
    if length(tradeZone) ~= nInstr
        error('tradeZone has not the right number of elements. Use marketIdx perhaps.')
    end
    % Categorize the instruments accordning to three trading zones.
    Asia = strcmp(tradeZone, 'ASIA'); %#ok
    Europe = strcmp(tradeZone, 'EUROPE');
    US = strcmp(tradeZone, 'USA');
end


POS    = nan(nDates,nInstr);
TRADLO = nan(nDates,nInstr);
TRADSO = nan(nDates,nInstr);
REVLO  = nan(nDates,nInstr);
REVSO  = nan(nDates,nInstr);

switch lower(tradeTime)
    case 'c'
        tradeSameDay = true(1,nInstr);
        tradeOnClose = true(1,nInstr);
    case 'l'
        tradeSameDay = true(1,nInstr);
        tradeOnClose = false(1,nInstr);
        hasLevelPrice = ~isnan(Pmid);
        Popen(hasLevelPrice) = Pmid(hasLevelPrice);
    case 'no'
        tradeSameDay = false(1,nInstr);
        tradeOnClose = false(1,nInstr);
    case 'nc'
        tradeSameDay = false(1,nInstr);
        tradeOnClose = true(1,nInstr);
    case 'euc'
        tradeSameDay = Europe|US;
        tradeOnClose = Europe|US;
    case 'uc'
        tradeSameDay = US;
        tradeOnClose = US;
    case 'eum'
        tradeSameDay = Europe|US;
        tradeOnClose = false(1,nInstr);
        Popen(:,Europe|US) = Pmid(:,Europe|US);
    case 'um'
        tradeSameDay = Europe|US;
        tradeOnClose = Europe;
        Popen(:,US) = Pmid(:,US);
    otherwise
        error(['Unknown tradeTime: ' tradeTime])
end


for i=1:nInstr
    
    if tradeSameDay(i)
        ix = ~isnan(Pclose(:,i)) & ~isnan(Popen(:,i)) & ~isnan(dPos(:,i));
        po = dPos(ix,i);
    else
        % Important to catch changes in dPos while a market is closed.
        ix = ~isnan(Pclose(:,i)) & ~isnan(Popen(:,i)) & ~isnan(dPos([1 1:end-1],i));
        dPosLag = [NaN; dPos(1:end-1,i)];
        po = dPosLag(ix);
    end
    
    op = Popen(ix,i);
    cl = Pclose(ix,i);
    N = [0 ; op(2:end)-cl(1:end-1)]; % N = price change at night
    D = cl-op; % D is price change during day (op->cl)

    % A small trick to get REV and TRAD correct the first trading day. Else
    % there might be a NaN problem. 
    startPosition = find(po >0 | po <0, 1);
    if startPosition > 1
        poBeforeStart = po(startPosition-1);
        po(startPosition-1) = 0;
    end
    
    poLO  = po.*(po>0);
    poSO  = po.*(po<0);

    if tradeOnClose(i)
        revLO = [0; poLO(1:end-1)] .* (N + D);
        revSO = [0; poSO(1:end-1)] .* (N + D);
    else
        % else we trade on open (or mid/level).
        revLO = [0; poLO(1:end-1)].*N + poLO .* D;
        revSO = [0; poSO(1:end-1)].*N + poSO .* D;
    end
    
    % Trading
    tradLO = abs(diff([0 ; poLO]));
    tradSO = abs(diff([0 ; poSO]));

    % Reset what might have been altered
    if startPosition > 1
        po(startPosition-1) = poBeforeStart;
    end
    
    % Put into the return matrices
    POS(ix,i) = po;
    REVLO(ix,i) = revLO;
    REVSO(ix,i) = revSO;
    TRADLO(ix,i) = tradLO;
    TRADSO(ix,i) = tradSO;
end

REV  = REVLO  + REVSO;
TRAD = TRADLO + TRADSO;

end

