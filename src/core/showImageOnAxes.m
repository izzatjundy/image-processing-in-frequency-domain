function showImageOnAxes(ax, img)
%SHOWIMAGEONAXES Display an image on UIAXES.

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
