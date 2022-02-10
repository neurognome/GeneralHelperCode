function out = skyline_wrap(varargin)

% For creating skyline plots, which are better for comparing two
% histograms. Completely preserves and is used just like histogram, call it
% the same

% Edited version that sets the first and last bins to the same value... can't do this with built in histogram, so have to remake it with bar
% Written 10Nov2021 KS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hold_flag = ishold(gca); % check hold status
counts = histcounts(varargin{1}, varargin{2});
norm_counts = counts ./ sum(counts);
norm_counts([1, end]) = norm_counts(1) + norm_counts(end);

step = mode(diff(varargin{2}));
bin_centers = varargin{2} + step/2;
bin_centers = bin_centers(1:end-1);

h = bar(bin_centers, norm_counts, 1);

% h = histogram(varargin{:});

% get the edges, which serve as x values
bin_edges = varargin{2};
% repeat it for bothends
bin_edges = reshape(repmat(bin_edges, [2, 1]), 1, []);

% values = h.Values;
values = norm_counts;
values = reshape(repmat(values, [2, 1]), 1, []);
values = cat(2, 0, values, 0); % add the lines going down to 0 at the ends
% assuming default color
colors = lines(100);
n_bars = numel(findall(gcf, 'type', 'bar')); % match color of the line

hold('on')
plot(bin_edges, values, 'Color', colors(n_bars, :), 'LineWidth', 2); % plot the line
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
