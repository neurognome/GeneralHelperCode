function out = rowrescale(in, lower, upper)
    if nargin < 2 || isempty(lower)
        lower = 0;
    end
    if nargin < 3 || isempty(upper)
        upper = 1;
    end
    out = rescale(in, lower, upper, 'InputMin', min(in, [], 2), 'InputMax', max(in, [], 2));
end