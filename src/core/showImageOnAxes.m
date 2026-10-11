function showImageOnAxes(ax, img)
%SHOWIMAGEONAXES Display an image on UIAXES ax. Tries IMSHOW first
%   (Image Processing Toolbox); falls back to plain IMAGE/IMAGESC so
%   the app still works without the toolbox.

    cla(ax);
    if isempty(img)
        ax.XTick = [];
        ax.YTick = [];
        return;
    end
    try
        imshow(img, 'Parent', ax);
    catch
        if ismatrix(img)
            imagesc(ax, img, [0 255]);
            colormap(ax, gray(256));
        else
            image(ax, img);
        end
        axis(ax, 'image');
    end
    ax.XTick = [];
    ax.YTick = [];
end
