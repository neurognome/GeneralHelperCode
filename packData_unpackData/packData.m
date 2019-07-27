function out = packData(varargin)
%-------------------------------------------------------------------------%
% A very simple way of bundling many output arguments to pass easily into
% another function. Mainly for my own use in passing data between methods
% for my OOP stuff.
%
% Written 26Jul2019 KS
%-------------------------------------------------------------------------%

for ii = 1:nargin
    out.(inputname(ii)) = varargin{ii};
end
end