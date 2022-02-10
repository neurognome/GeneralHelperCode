function out = skyline(varargin)

% For creating skyline plots, which are better for comparing two
% histograms. Completely preserves and is used just like histogram, call it
% the same

% Written 05Nov2021 KS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hold_flag = ishold(gca); % check hold status

h = histogram(varargin{:});

% get the edges, which serve as x values
bin_edges = h.BinEdges;
% repeat it for bothends
bin_edges = reshape(repmat(bin_edges, [2, 1]), 1, []);

values = h.Values;
values = reshape(repmat(values, [2, 1]), 1, []);
values = cat(2, 0, values, 0); % add the lines going down to 0 at the ends

% assuming default color
colors = lines(100);
n_histograms = numel(findall(gcf, 'type', 'histogram')); % match color of the line

hold('on')
if strcmp(h.FaceColor, 'auto')
plot(bin_edges, values, 'Color', colors(n_histograms, :), 'LineWidth', 2); % plot the line
else
plot(bin_edges, values, 'Color', h.FaceColor, 'LineWidth', 2); % if FaceColor is manually set
end
hold('off')

if hold_flag % restore hold state
    hold('on')
else
    hold('off')
end

% Pretty-fy
h.EdgeAlpha = 0; % get rid of the edges
h.FaceAlpha = 0.15; % reduce transparency

if nargout > 0
    out = h;
end
end
