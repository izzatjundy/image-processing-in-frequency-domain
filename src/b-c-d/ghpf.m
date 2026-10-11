function H = ghpf(D, D0)
%GHPF Gaussian High-Pass Filter transfer function.
    H = 1 - glpf(D, D0);
end
