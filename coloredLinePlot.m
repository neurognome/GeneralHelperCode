function out = coloredLinePlot(var1, var2, var3, linewidth)
% plots var1 against var2, colored by var3

% Written 12Nov2020 KS

% ensure that the three vectors are the same length
try 
    cat(1, var1(:), var2(:), var3(:)); % this is dirty af but it'll work
catch
    error('Three vectors are not the same length')
end
var1 = [var1(:); NaN]; 
var2 = [var2(:); NaN]; 
var3 = [var3(:); NaN]; 

vector_length = length(var1);

c = patch(var1, var2, rescale(var3), 'EdgeColor','interp', 'Linewidth', linewidth);

if nargout > 0
	out = c;
end
