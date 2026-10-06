function [U, V] = centeredFreqGrid(rows, cols)
%CENTEREDFREQGRID Centered (u,v) frequency coordinate grids, the same
%   convention used by DISTANCEFROMCENTER (u=0,v=0 at the spectrum
%   center after FFTSHIFT). Useful for filters that need direction,
%   not just radius -- e.g. NOTCHREJECTFILTER and MOTIONBLURPSF.
%   Shared infrastructure, built with MESHGRID.
    u = (0:rows-1) - floor(rows/2);
    v = (0:cols-1) - floor(cols/2);
    [V, U] = meshgrid(v, u);
end
