function logMag = computeLogSpectrum(I)
%COMPUTELOGSPECTRUM Centered, log-scaled magnitude spectrum of a
%   single-channel image: log(1 + |fftshift(fft2(I))|). A raw linear
%   spectrum is almost never readable, so every spectrum display in
%   this app goes through this function.
    I = double(I);
    F = fftshift(fft2(I));
    logMag = log(1 + abs(F));
end
