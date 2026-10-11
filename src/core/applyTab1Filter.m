function [J, H, methodLabel, paramStr] = applyTab1Filter(I, groupKey, variantKey, params)
%APPLYTAB1FILTER Dispatch to the right Tab-1 transfer function
%   (Parts B, C, D), apply it channel-by-channel via
%   APPLYFREQFILTER, and return the result, the mask H(u,v) (for
%   display), and labels for the status bar / report.
    [rows, cols] = size(I(:, :, 1));
    D = distanceFromCenter(rows, cols);
    absoluteOutput = false;

    switch groupKey
        case 'lowpass'
            switch variantKey
                case 'ideal'
                    H = ilpf(D, params.D0);
                    methodLabel = 'Ideal Low-Pass Filter';
                    paramStr = sprintf('D0=%g', params.D0);
                case 'gaussian'
                    H = glpf(D, params.D0);
                    methodLabel = 'Gaussian Low-Pass Filter';
                    paramStr = sprintf('D0=%g', params.D0);
                case 'butterworth'
                    H = blpf(D, params.D0, params.n);
                    methodLabel = 'Butterworth Low-Pass Filter';
                    paramStr = sprintf('D0=%g, n=%g', params.D0, params.n);
                otherwise
                    error('applyTab1Filter:unknownVariant', 'Unknown low-pass variant: %s', variantKey);
            end
        case 'highpass'
            absoluteOutput = true;
            switch variantKey
                case 'ideal'
                    H = ihpf(D, params.D0);
                    methodLabel = 'Ideal High-Pass Filter';
                    paramStr = sprintf('D0=%g', params.D0);
                case 'gaussian'
                    H = ghpf(D, params.D0);
                    methodLabel = 'Gaussian High-Pass Filter';
                    paramStr = sprintf('D0=%g', params.D0);
                case 'butterworth'
                    H = bhpf(D, params.D0, params.n);
                    methodLabel = 'Butterworth High-Pass Filter';
                    paramStr = sprintf('D0=%g, n=%g', params.D0, params.n);
                otherwise
                    error('applyTab1Filter:unknownVariant', 'Unknown high-pass variant: %s', variantKey);
            end
        case 'brightness'
            H = brightnessEmphasisFilter(D, params.D0, params.gain);
            methodLabel = 'Frequency-Domain Brightness Emphasis';
            paramStr = sprintf('D0=%g, gain=%g', params.D0, params.gain);
        otherwise
            error('applyTab1Filter:unknownGroup', 'Unknown group: %s', groupKey);
    end

    J = applyChannelwise(I, @(ch) applyFreqFilter(ch, H, absoluteOutput));
end
