function J = applyFreqFilter(I, H, absoluteOutput)
%APPLYFREQFILTER Apply a (possibly complex) frequency-domain transfer
%   function H(u,v) to a single-channel image I. By default, return a
%   clipped uint8 image; ABSOLUTEOUTPUT returns the magnitude of the
%   inverse-filtered response as uint8, for high-pass display. This is
%   shared infrastructure used by techniques in Tabs 1-3.
%
%   H must be the same size as I and already centered to match
%   FFTSHIFT(FFT2(I)), i.e. H's own center corresponds to the DC term.
%   For color images, call this once per channel (see
%   APPLYCHANNELWISE) and recombine.
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
