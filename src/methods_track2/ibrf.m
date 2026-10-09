function H = ibrf(D, D0, W)
%IBRF Ideal Bandreject Filter transfer function.
    H = ones(size(D));
    bandMask = (D >= (D0 - W/2)) & (D <= (D0 + W/2));
    H(bandMask) = 0;
end
