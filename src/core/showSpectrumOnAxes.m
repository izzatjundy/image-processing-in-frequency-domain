function showSpectrumOnAxes(ax, I, H)
%SHOWSPECTRUMONAXES Plot the log-magnitude centered spectrum of I (for
%   color images, computed on a luminance approximation) onto UIAXES
%   ax. If H is provided, show the spectrum after applying H to I.
    cla(ax);
    if isempty(I)
        ax.XTick = [];
        ax.YTick = [];
        return;
    end
    if ndims(I) == 3 && size(I, 3) == 3
        grayImg = 0.299 * double(I(:,:,1)) + 0.587 * double(I(:,:,2)) + 0.114 * double(I(:,:,3));
    else
        grayImg = double(I);
    end
    if nargin >= 3
        logMag = computeLogSpectrum(grayImg, H);
    else
        logMag = computeLogSpectrum(grayImg);
    end
    imagesc(ax, logMag);
    colormap(ax, gray(256));
    axis(ax, 'image');
    ax.XTick = [];
    ax.YTick = [];
end
