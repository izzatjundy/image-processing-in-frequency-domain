function D = distanceFromCenter(rows, cols)
%DISTANCEFROMCENTER Centered distance matrix D(u,v) for frequency-domain
%   filter design. D is the same size as a centered (FFTSHIFT-ed)
%   spectrum, with D = 0 at the center growing outward. Built with
%   MESHGRID, which the assignment explicitly allows to be used
%   directly (Ketentuan Umum A.3) -- shared infrastructure, neither
%   track needs to rewrite this.
    u = (0:rows-1) - floor(rows/2);
    v = (0:cols-1) - floor(cols/2);
    [V, U] = meshgrid(v, u);
    D = sqrt(U.^2 + V.^2);
end
