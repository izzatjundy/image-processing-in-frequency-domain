function logMag = computeLogSpectrum(I, H)
%COMPUTELOGSPECTRUM Compute a centered, log-scaled Fourier magnitude spectrum.
    I = double(I);
    F = fftshift(fft2(I));
    if nargin >= 2 && ~isempty(H)
        if ~isequal(size(F), size(H))
            error('computeLogSpectrum:sizeMismatch', ...
                'The transfer function must match the image spectrum size.');
        end
        F = F .* H;
    end
    logMag = log(1 + abs(F));
end
