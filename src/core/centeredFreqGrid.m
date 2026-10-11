function [U, V] = centeredFreqGrid(rows, cols)
%CENTEREDFREQGRID Create centered frequency-coordinate grids.
    u = (0:rows-1) - floor(rows/2);
    v = (0:cols-1) - floor(cols/2);
    [V, U] = meshgrid(v, u);
end
