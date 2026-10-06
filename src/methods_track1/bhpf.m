function H = bhpf(D, D0, n)
%BHPF Butterworth High-Pass Filter transfer function.
    H = 1 - blpf(D, D0, n);
end
