function H = notchRejectFilter(rows, cols, notchPoints, D0)
%NOTCHREJECTFILTER Combine several notch-pair rejections into one
    if nargin < 4 || isempty(D0)
        D0 = 6;
    end

    [U, V] = centeredFreqGrid(rows, cols);
    H = ones(rows, cols);
    n = 2;

    numNotches = size(notchPoints, 1);
    for k = 1:numNotches
        u0 = notchPoints(k,1);
        v0 = notchPoints(k,2);

        % Jarak ke titik notch dan simetrinya
        Dk = sqrt((U - u0).^2 + (V - v0).^2);
        D_min_k = sqrt((U + u0).^2 + (V + v0).^2);

        denom = Dk .* D_min_k;
        Hk = ones(rows, cols);
        
        % Handle biar ga divide by zero
        exactZeros = (denom == 0);
        Hk(exactZeros) = 0;

        valid = ~exactZeros;
        term = (D0^2) ./ denom(valid);
        Hk(valid) = 1 ./ (1 + term.^n);

        H = H .* Hk;
    end
end
