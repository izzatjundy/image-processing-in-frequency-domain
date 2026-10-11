function H = ilpf(D, D0)
%ILPF Ideal Low-Pass Filter transfer function.
    H = double(D <= D0);
end
