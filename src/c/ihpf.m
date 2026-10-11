function H = ihpf(D, D0)
%IHPF Ideal High-Pass Filter transfer function.
    H = 1 - ilpf(D, D0);
end
