function J = applyFreqFilter(I, H, absoluteOutput)
%APPLYFREQFILTER Apply a frequency-domain mask and return the spatial result.
    if nargin < 3
        absoluteOutput = false;
    end

    I = double(I);
    F = fft2(I);
    Fshift = fftshift(F);
    Gshift = Fshift .* H;
    G = ifftshift(Gshift);
    g = ifft2(G);
    g = real(g);
    if absoluteOutput
        J = uint8(abs(g));
    else
        J = uint8(min(max(g, 0), 255));
    end
end
