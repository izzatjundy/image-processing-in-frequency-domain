function H = bbrf(D, D0, W, n)
%BBRF Butterworth Bandreject Filter transfer function.
    if nargin < 4 || isempty(n)
        n = 2;
    end
    
    H = ones(size(D));
    denom = D.^2 - D0^2;
    H(denom == 0) = 0;
    
    valid = (denom ~= 0);
    term = (D(valid)*W) ./ denom(valid);
    H(valid) = 1 ./ (1 + term.^(2*n));

end
