function D = distanceFromCenter(rows, cols)
%DISTANCEFROMCENTER Compute distances from the centered frequency origin.
    u = (0:rows-1) - floor(rows/2);
    v = (0:cols-1) - floor(cols/2);
    [V, U] = meshgrid(v, u);
    D = sqrt(U.^2 + V.^2);
end
