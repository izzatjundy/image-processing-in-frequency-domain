function logMag = computeLogSpectrum(I, H)
%COMPUTELOGSPECTRUM Centered, log-scaled magnitude spectrum of a
%   single-channel image: log(1 + |fftshift(fft2(I))|). A raw linear
%   spectrum is almost never readable, so every spectrum display in
%   this app goes through this function. If H is supplied, apply the
%   centered transfer function to the spectrum before taking magnitude.
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
