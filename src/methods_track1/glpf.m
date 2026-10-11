function H = glpf(D, D0)
%GLPF Gaussian Low-Pass Filter transfer function.
    H = exp(-(D.^2) ./ (2 * D0^2));
end
