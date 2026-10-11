function H = blpf(D, D0, n)
%BLPF Butterworth Low-Pass Filter transfer function.
    H = 1 ./ (1 + (D ./ D0).^(2 * n));
end
