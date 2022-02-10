function aligned_responses = oddEvenAligner(trial_responses, reference_idx, alignment_idx)

	if nargin < 2 || isempty(reference_idx)
		reference_idx = 1;
	end

	if nargin < 3 || isempty(alignment_idx)
		alignment_idx = 15;
	end

	reference_odd = trial_responses{reference_idx}(:, :, 1:2:end);
	reference_even = trial_responses{reference_idx}(:, :, 2:2:end);

	[~, odd_idx] = max(movmean(mean(reference_odd, 3), 5, 2), [], 2);
	[~, even_idx] = max(movmean(mean(reference_even, 3), 5, 2), [], 2);

	aligned_responses = cell(1, length(trial_responses));
	for s = 1:length(trial_responses) % segment
		aligned_responses{s} = zeros(size(trial_responses{s}));
        odd_aligned = zeros(size(trial_responses{s}(:, :, 1:2:end)));
        even_aligned = zeros(size(trial_responses{s}(:, :, 2:2:end)));
		for c = 1:size(trial_responses{s}, 1)
			odd_aligned(c, :, :) = circshift(trial_responses{s}(c, :, 1:2:end), 15 - even_idx(c), 2);
			even_aligned(c, :, :) = circshift(trial_responses{s}(c, :, 2:2:end), 15 - odd_idx(c), 2);
		end

		% interleave
		% aligned_responses{s} = odd_aligned;
		aligned_responses{s}(:, :, 1:2:end) = odd_aligned;
		aligned_responses{s}(:, :, 2:2:end) = even_aligned;
	end
end
