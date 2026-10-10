function H = motionBlurPSF(rows, cols, a, b, T)
%MOTIONBLURPSF Linear motion-blur degradation transfer function
    if nargin < 5 || isempty(T)
        T = 1;
    end

    u = ((0:rows-1) - floor(rows/2)) / rows;
    v = ((0:cols-1) - floor(cols/2)) / cols;
    [V,U] =  meshgrid(v,u);

    motionTerm = U * a + V * b;
    phaseTerm = exp(-1i * pi * motionTerm);
    H = T * sinc(motionTerm) .* phaseTerm;
end