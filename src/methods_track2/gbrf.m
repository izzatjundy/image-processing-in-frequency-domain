function H = gbrf(D, D0, W)
%GBRF Gaussian Bandreject Filter transfer function.
    H = ones(size(D));
    nonzero = (D > 0);
    term = (D(nonzero).^2 - D0^2) ./ (D(nonzero)*W);
    H(nonzero) = 1 - exp(-0.5 * (term.^2));
end
