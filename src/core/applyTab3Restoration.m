function [Jinv, Jwien, H] = applyTab3Restoration(I, a, b, T, radiusLimit, K)
%APPLYTAB3RESTORATION Restore a motion-blurred image using inverse and Wiener filters.
    [rows, cols] = size(I(:, :, 1));
    H = motionBlurPSF(rows, cols, a, b, T);

    Jinv = applyChannelwise(I, @(ch) inverseFilterRestore(ch, H, radiusLimit));
    Jwien = applyChannelwise(I, @(ch) wienerFilterRestore(ch, H, K));
end
