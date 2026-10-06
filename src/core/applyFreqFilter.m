function J = applyFreqFilter(I, H)
%APPLYFREQFILTER Apply a (possibly complex) frequency-domain transfer
%   function H(u,v) to a single-channel image I and return the
%   filtered, uint8-cast result. This is shared infrastructure used by
%   every technique in Tabs 1-3 (B, C, D, E, F) -- neither track needs
%   to rewrite it; only the H(u,v) builders differ per technique.
%
%   H must be the same size as I and already centered to match
%   FFTSHIFT(FFT2(I)), i.e. H's own center corresponds to the DC term.
%   For color images, call this once per channel (see
%   APPLYCHANNELWISE) and recombine.
    I = double(I);
    F = fft2(I);
    Fshift = fftshift(F);
    Gshift = Fshift .* H;
    G = ifftshift(Gshift);
    g = ifft2(G);
    g = real(g);
    J = uint8(min(max(g, 0), 255));
end
