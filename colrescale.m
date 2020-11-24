function out = colrescale(in, lower, upper)
    if nargin < 2 || isempty(lower)
        lower = 0;
    end
    if nargin < 3 || isempty(upper)
        upper = 1;
    end
    out = rescale(in, lower, upper, 'InputMin', min(in), 'InputMax', max(in));
end