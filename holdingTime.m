function [htime, htime_sign] = holdingTime( pos )

[T,N] = size(pos);
side = sign(pos);
sign_flips = NansumNan(NansumNan(abs(side(2:T,:)-side(1:T-1,:))));
htime_sign = 2*T*N/sign_flips;
htime = NansumNan(NansumNan(abs(pos)))/NansumNan(NansumNan(abs(pos(2:T,:)-pos(1:T-1,:))));
end

