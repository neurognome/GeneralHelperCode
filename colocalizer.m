function is_red_labeled = colocalizer(data, red_data, method)
% The purpose of this funciton is to take two images and figure out the "colocalization" between the two images. eg, take an
% activity map and figure out which ROIs are present on the second image. Offers two methods: overlap and mean. Overlap
% thresholds the map and then calculates overlap between each cell mask and the red reference, then considers cells with
% greater than some amt of overlap to be colocalized. Mean takes the mean fluorescence at each cell mask and uses the
% percentile to consider "bright enough" cells as colocalized.

% Written 07Nov2019 KS
% Updated 
if nargin < 1 || isempty(data)
    disp('Choose your imaging data...')
    [fn, pn] =  uigetfile('*.mat');
    data = importdata([pn '\' fn]);
end

if nargin < 2 || isempty(red_data)
    disp('Choose your red reference...')
    [fn, pn] =  uigetfile('*.mat');
    red_data = importdata([pn '\' fn]);
end

if nargin < 3 || isempty(method)
    method = questdlg('What method do you want to use?',  'Method', 'overlap', 'mean', 'overlap');
end

% Take the cell masks from data
cell_masks = data.cellMasks;
red_projection = red_data.avg_projection;

% Use the cell masks to get values from red_data's avg projection        
img_size = size(red_projection);
switch method
    case 'overlap'
        red_cells = subroutine_autodetect(red_projection); % Take advantage of the our autodetect from B_DefineROI
        for i_cell = 1:length(cell_masks)
            roi = poly2mask(cell_masks{i_cell}(:, 1), cell_masks{i_cell}(:, 2), img_size(1), img_size(2));          
            overlap(i_cell) = sum(sum(roi & red_cells));  
        end
        is_red_labeled = overlap > 50; % more than 50 pixels overlap
    case 'mean'
        
        for i_cell = 1:length(cell_masks)
            roi = poly2mask(cell_masks{i_cell}(:, 1), cell_masks{i_cell}(:, 2), img_size(1), img_size(2));
            mean_red_f(i_cell) = mean(red_projection(roi));
        end
        is_red_labeled = mean_red_f > prctile(mean_red_f, 90);
end


% Histogram of the stuff of red_data, then hopefully there's a nice distribution right?
%
% img = zeros(760);
% for i_cell = 1:length(cell_masks)
%     if is_red_labeled(i_cell)
%             roi = poly2mask(cell_masks{i_cell}(:, 1), cell_masks{i_cell}(:, 2), img_size(1), img_size(2));
%         img = img + roi;
%     end
% end
% 

end