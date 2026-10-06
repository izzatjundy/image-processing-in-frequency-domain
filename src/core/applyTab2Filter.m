function [J, H, methodLabel, paramStr] = applyTab2Filter(I, groupKey, variantKey, params, notchPoints)
%APPLYTAB2FILTER Dispatch to the right Tab-2 restoration filter
%   (Part E). NOTCHPOINTS is an Nx2 matrix of (u0, v0) pairs, used
%   only when variantKey is 'notch'.
    [rows, cols] = size(I(:, :, 1));
    D = distanceFromCenter(rows, cols);

    switch groupKey
        case 'bandreject'
            switch variantKey
                case 'ideal'
                    H = ibrf(D, params.D0, params.W);
                    methodLabel = 'Ideal Bandreject Filter';
                    paramStr = sprintf('D0=%g, W=%g', params.D0, params.W);
                case 'gaussian'
                    H = gbrf(D, params.D0, params.W);
                    methodLabel = 'Gaussian Bandreject Filter';
                    paramStr = sprintf('D0=%g, W=%g', params.D0, params.W);
                case 'butterworth'
                    H = bbrf(D, params.D0, params.W, params.n);
                    methodLabel = 'Butterworth Bandreject Filter';
                    paramStr = sprintf('D0=%g, W=%g, n=%g', params.D0, params.W, params.n);
                otherwise
                    error('applyTab2Filter:unknownVariant', 'Unknown bandreject variant: %s', variantKey);
            end
        case 'notch'
            if nargin < 5 || isempty(notchPoints)
                error('applyTab2Filter:noNotchPoints', 'Add at least one notch point before running.');
            end
            H = notchRejectFilter(rows, cols, notchPoints, params.D0);
            methodLabel = 'Notch Reject Filter';
            paramStr = sprintf('%d notch pair(s), D0=%g', size(notchPoints, 1), params.D0);
        otherwise
            error('applyTab2Filter:unknownGroup', 'Unknown group: %s', groupKey);
    end

    J = applyChannelwise(I, @(ch) applyFreqFilter(ch, H));
end
