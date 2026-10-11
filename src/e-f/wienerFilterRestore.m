function J = wienerFilterRestore(I, H, K)
%WIENERFILTERRESTORE Own Wiener-filtering restoration (Part F).
    if nargin < 3 || isempty(K)
        K = 0.01;
    end
    
    % Transform ke ranah frekuensi
    I = double(I);
    G = fftshift(fft2(I));

    % Wiener filtering
    H_conj = conj(H);
    H_mag2 = abs(H).^2;
    W_filter = H_conj ./ (H_mag2 + K);

    F_est = G .* W_filter;

    % Ranah spasial
    f_est = real(ifft2(ifftshift(F_est)));
    J = uint8(min(max(f_est, 0), 255));
end
