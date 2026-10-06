function registry = filterRegistryTab1()
%FILTERREGISTRYTAB1 Groups/variants/parameters for the Frequency
%   Filtering tab (Parts B, C, D). The GUI builds its dropdowns and
%   parameter panel from this -- add a variant here and it appears in
%   the app with no other code changes.
    registry = struct('Key', {}, 'Label', {}, 'Variants', {});

    registry(end+1) = struct('Key', 'lowpass', 'Label', 'Low-Pass Filtering', 'Variants', variantList( ...
        variant('ideal', 'Ideal (ILPF)', {param('D0', 'D0 (cutoff)', 30, 1, 200, 1)}), ...
        variant('gaussian', 'Gaussian (GLPF)', {param('D0', 'D0 (cutoff)', 30, 1, 200, 1)}), ...
        variant('butterworth', 'Butterworth (BLPF)', { ...
            param('D0', 'D0 (cutoff)', 30, 1, 200, 1), param('n', 'n (order)', 2, 1, 10, 1)}) ...
    ));

    registry(end+1) = struct('Key', 'highpass', 'Label', 'High-Pass Filtering', 'Variants', variantList( ...
        variant('ideal', 'Ideal (IHPF)', {param('D0', 'D0 (cutoff)', 30, 1, 200, 1)}), ...
        variant('gaussian', 'Gaussian (GHPF)', {param('D0', 'D0 (cutoff)', 30, 1, 200, 1)}), ...
        variant('butterworth', 'Butterworth (BHPF)', { ...
            param('D0', 'D0 (cutoff)', 30, 1, 200, 1), param('n', 'n (order)', 2, 1, 10, 1)}) ...
    ));

    registry(end+1) = struct('Key', 'brightness', 'Label', 'Brightness Enhancement', 'Variants', variantList( ...
        variant('emphasis', 'Frequency-Domain Emphasis', { ...
            param('D0', 'D0', 30, 1, 200, 1), param('gain', 'gain', 1.5, 1, 5, 0.1)}) ...
    ));
end

function v = variant(key, label, params)
    if isempty(params)
        v.Params = struct('Name', {}, 'Label', {}, 'Default', {}, 'Min', {}, 'Max', {}, 'Step', {});
    else
        v.Params = [params{:}];
    end
    v.Key = key;
    v.Label = label;
end

function list = variantList(varargin)
    list = [varargin{:}];
end

function p = param(name, label, default, minVal, maxVal, step)
    p.Name = name;
    p.Label = label;
    p.Default = default;
    p.Min = minVal;
    p.Max = maxVal;
    p.Step = step;
end
