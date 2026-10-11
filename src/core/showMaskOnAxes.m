function showMaskOnAxes(ax, H)
%SHOWMASKONAXES Display the magnitude of a frequency-domain mask.
    cla(ax);
    if isempty(H)
        ax.XTick = [];
        ax.YTick = [];
        return;
    end
    M = abs(H);
    m = max(M(:));
    if m > 0
        M = M / m;
    end
    imagesc(ax, M, [0 1]);
    colormap(ax, gray(256));
    axis(ax, 'image');
    ax.XTick = [];
    ax.YTick = [];
end
