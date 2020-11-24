function [out, max_idx] = alignByMax(data, offset, max_idx)
if nargin < 2
    offset = 1;
end

if nargin < 3
    [~, max_idx] = max(data, [], 2);
end

out = zeros(size(data));
for ii = 1:size(data, 1)
    out(ii, :) = circshift(data(ii, :), offset - max_idx(ii));
end
