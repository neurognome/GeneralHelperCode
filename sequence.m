function [out, sorting_vector] = sequence(in)
% Simple function to do a couple of things we usually do to sort things by their max, good for place cells, etc anythnig with
% a sequency

[~, idx] = max(in, [], 2);
[~, sorting_vector] = sort(idx);
out = in(sorting_vector, :);