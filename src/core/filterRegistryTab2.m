function registry = filterRegistryTab2()
%FILTERREGISTRYTAB2 Groups/variants/parameters for the Periodic Noise
%   Restoration tab (Part E). Notch Reject has no numeric params here
%   besides a shared radius -- its center points come from a separate
%   editable table in the GUI, not this parameter panel.
    registry = struct('Key', {}, 'Label', {}, 'Variants', {});

    registry(end+1) = struct('Key', 'bandreject', 'Label', 'Bandreject Filter', 'Variants', variantList( ...
        variant('ideal', 'Ideal', { ...
            param('D0', 'D0 (center radius)', 40, 1, 250, 1), param('W', 'W (bandwidth)', 10, 1, 80, 1)}), ...
        variant('gaussian', 'Gaussian', { ...
            param('D0', 'D0 (center radius)', 40, 1, 250, 1), param('W', 'W (bandwidth)', 10, 1, 80, 1)}), ...
        variant('butterworth', 'Butterworth', { ...
            param('D0', 'D0 (center radius)', 40, 1, 250, 1), param('W', 'W (bandwidth)', 10, 1, 80, 1), ...
            param('n', 'n (order)', 2, 1, 10, 1)}) ...
    ));

    registry(end+1) = struct('Key', 'notch', 'Label', 'Notch Reject Filter', 'Variants', variantList( ...
        variant('notch', 'Notch Reject (uses the point table)', { ...
            param('D0', 'D0 (radius per notch)', 6, 1, 40, 1)}) ...
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
