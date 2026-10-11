function H = brightnessEmphasisFilter(D, D0, gain)
%BRIGHTNESSEMPHASISFILTER Frequency-domain brightness-enhancement
    H = 1 + (gain - 1) .* glpf(D, D0);
end
