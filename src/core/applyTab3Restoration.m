function [Jinv, Jwien, H] = applyTab3Restoration(I, a, b, T, radiusLimit, K)
%APPLYTAB3RESTORATION Build the motion-blur PSF and run both inverse
%   filtering and Wiener filtering on I, channel-by-channel. Returns
%   both results plus the PSF (for display) so the GUI can show
%   everything the assignment requires for Part F in one call.
    [rows, cols] = size(I(:, :, 1));
    H = motionBlurPSF(rows, cols, a, b, T);

    Jinv = applyChannelwise(I, @(ch) inverseFilterRestore(ch, H, radiusLimit));
    Jwien = applyChannelwise(I, @(ch) wienerFilterRestore(ch, H, K));
end
