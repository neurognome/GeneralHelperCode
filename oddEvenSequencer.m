function [odd_idx, even_resp] = oddEvenSequencer(trial_responses, reference_idx)
	if nargin < 2 || isempty(reference_idx)
		reference_idx = 1;
	end
	
    for r = 1:length(reference_idx)
        reference_odd{r} = trial_responses{reference_idx(r)}(:, :, 1:2:end);
    end
% 	reference_even = trial_responses{reference_idx}(:, :, 2:2:end);
    temp = cellfun(@(x) mean(x, 3), reference_odd, 'UniformOutput', false);
    reference_odd =  cat(3, temp{:});
    [~, odd_idx] = max(mean(reference_odd, 3), [], 2);    
    
    [~, sort_vec] = sort(odd_idx);
    for s = 1:numel(trial_responses)
        even_resp{s} = trial_responses{s}(:, :, 2:2:end); %evens only
    end
    
% 
%     theta_q = linspace(0, 2*pi, 60);
%     for c = 1:size(trial_responses{reference_idx}, 1)
%         [~, max_idx_pool] = max(reference_odd(c, :, :), [], 2);
%         center(c) = circ_mean(theta_q(max_idx_pool)');
%     end
%     
% 	[~, sort_vec] = sort(center);	
% 	
% 
% 	for s = 1:length(trial_responses)
% 		sequenced_responses{s} = trial_responses{s}(sort_vec, :, 2:2:end);
%     end
