function J = applyChannelwise(I, fn)
%APPLYCHANNELWISE Apply a single-channel function FN to every channel
%   of I, recombining color images automatically. Shared
%   infrastructure reused across both tracks.
    if ndims(I) == 3 && size(I, 3) == 3
        firstChannel = fn(I(:, :, 1));
        J = zeros(size(I), 'like', firstChannel);
        J(:, :, 1) = firstChannel;
        for c = 2:3
            J(:, :, c) = fn(I(:, :, c));
        end
    else
        J = fn(I);
    end
end
