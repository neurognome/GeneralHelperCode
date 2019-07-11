function curr_cell = cellArrayAggregator(curr_cell, var_name)
% Takes a variable name that you specify and aggregates it into the cell array that you choose

if nargin == 0
    fprintf('You have an issue... you forgot to specific your variable of interest... \n')
    return
end

% First let's search the workspace for the variable that we specified
curr_cell{length(curr_cell)+1} = evalin('base',var_name);
end
