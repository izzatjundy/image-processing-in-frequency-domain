function J = inverseFilterRestore(I, H, radiusLimit)
%INVERSEFILTERRESTORE Own inverse-filtering restoration (Part F).
    if nargin < 3 || isempty(radiusLimit)
        radiusLimit = 60;
    end

    % Transform ke ranah frekuensi
    I = double(I);
    [rows,cols] = size(I);
    G = fftshift(fft2(I));

    D = distanceFromCenter(rows,cols);

    % Inverse filtering
    F_est = zeros(rows,cols);
    validMask = (D <= radiusLimit) & (abs(H) > 1e-3);
    F_est(validMask) = G(validMask) ./ H(validMask);

    % Ranah spasial
    f_est = real(ifft2(ifftshift(F_est)));
    J = uint8(min(max(f_est, 0), 255));
end
