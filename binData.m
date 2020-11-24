function out = binData(input, binning_metric, n_bins)
	groups = discretize(binning_metric, n_bins);
	unique_groups = unique(groups);
	
	out = zeros(numel(unique_groups), size(input, 2));
	for g = 1:length(unique_groups)
		out(g, :) = mean(input(groups == unique_groups(g), :), 1);
	end
end