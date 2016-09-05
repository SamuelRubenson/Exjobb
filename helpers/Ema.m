function Y = Ema(X, a, warmStart, warmStartLength, noNans, backFill)

% function Y = Ema(X, a, warmStart, warmStartLength, noNans, backFill)
%
% Computes the EMA filter Y_k = (1-a)*Y_{k-1} + a*X_k
% for each column of X (disregarding NaN entries).
% If warmStart is true, the filter is initialised with the first non-zero
% element of the respective columns; if this variable is false the filter
% is initialised with zero. warmStart defaults to false.
% If warmStartLength is specified, the filter is initialized with the mean
% value of the first (non-NaN) warmStartLength elements, and the output matrix Y
% contains NaN in the first (non-NaN) warmStartLength-1 elements. If
% different columns should have different warmStartLengths, let
% warmStartLength be a vector matching the number of columns. This
% functionality only works if noNans is false (=default value, see below).
%
% If noNans is set to true, no check for NaNs is done and the function is
% executed faster. Much faster if X is a matrix. Default value is false.
%
% If backFill=true and warmStart=true and warmStartLength > 1, then the
% leading rows of the result is not returned as NaN, but instead backfilled
% with the value at row warmStartLength (ie the average of the first
% warmStartLength values). Default value for backFill: false.
%
if ~exist('warmStart','var') || isempty(warmStart), warmStart = false; end
if ~exist('warmStartLength','var') || isempty(warmStartLength) || ~warmStart, warmStartLength = 1; end
if ~exist('noNans','var') || isempty(noNans), noNans = false; end
if ~exist('backFill','var') || isempty(backFill), backFill = false; end

if noNans
    nCols = size(X,2);
    startMean = nan(1,nCols);
    if warmStart
        initCond = mean(X(1:warmStartLength,:),1) - a*X(warmStartLength,:);
        if backFill
            startMean = mean(X(1:warmStartLength,:),1);
        end
    else
        initCond = zeros(1,nCols);
    end
    Y = [repmat(startMean, warmStartLength-1,1); filter(a, [1, -(1-a)], X(warmStartLength:end,:), initCond, 1)];
    return
end

Y = NaN(size(X));
if numel(warmStartLength) == 1
    warmStartLength = ones(size(X,2), 1) * warmStartLength;
end
for c = 1:size(X,2)
    notNan = find(~isnan(X(:,c)));
    startMean = nan;
    if warmStart
        if numel(notNan) < warmStartLength
            continue
        end
        %initCond = mean(X(notNan(1:warmStartLength(c)),c)) - a*X(notNan(warmStartLength(c)),c);
        initCond = sum(X(notNan(1:warmStartLength(c)),c))/numel(notNan(1:warmStartLength(c))) - a*X(notNan(warmStartLength(c)),c); % Slightly faster
        if backFill
            startMean = mean(X(notNan(1:warmStartLength(c)),c));
        end
    else
        initCond = 0;
    end
    Y(notNan,c) = [ones(warmStartLength(c)-1,1)*startMean; filter(a, [1, -(1-a)], X(notNan(warmStartLength(c):end),c), initCond, 1)];
end

