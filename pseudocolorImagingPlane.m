function pseudocolorImagingPlane(data_structure, metric, map, cmap, choose_vector)
% This function takes your data structure (generally just called "data"),
% and some metric (which has a size 1 x cells) then uses that metric to
% pseudocolor the chosen map

baseAlpha = 0.5; % Base amount of see-through

if nargin < 2 
    error('Input data structure and metric to color by');
end

if nargin < 3 || isempty(map)
    map = questdlg('Which map do you want as the base?', 'Base Map', 'Activity Map', 'Average Projection', 'Activity Map');
end

if nargin < 4 || isempty(cmap)
    cmap = 'parula';
end

if nargin < 5 || isempty(choose_vector)
    choose_vector = true(1, size(data_structure.DFF, 1));
end

switch map
    case 'Activity Map'
        baseMap = data_structure.activity_map;
    case 'Average Projection'
        baseMap = data_structure.avg_projection;
end

overlayMap = zeros([size(baseMap), 3]);
transparencyMap = zeros(size(baseMap));
metric = rescale(metric(choose_vector));
metric(isnan(metric)) = 0;
metric = round(metric * 254) + 1;

try
    eval(['colors = ' cmap '(255);']);
catch
    colors = cmap;
end
cellMasks = data_structure.cellMasks(choose_vector);

for c = 1:length(cellMasks)
    isCurrCell = poly2mask(cellMasks{c}(:, 1), cellMasks{c}(:, 2), size(overlayMap, 1), size(overlayMap, 2));
    for rgb = 1:3
        temp = overlayMap(:, :, rgb);
        temp(isCurrCell) = colors(metric(c), rgb);
        overlayMap(:, :, rgb) = temp;
    end
    transparencyMap = transparencyMap + isCurrCell;
end
% Feathering to look better

transparencyMap = double(logical(transparencyMap));  % To account for overlap 
transparencyMap = imgaussfilt(transparencyMap, 2);
transparencyMap = transparencyMap * baseAlpha;

%% Display the plots
image(rescale(baseMap) * 80); % show the average projection,
%converted to RGB for compatibility
hold on
colormap gray

h = imagesc(overlayMap);
set(h, 'AlphaData', transparencyMap); % Set the transparency of the base 
% color map to the transparency defined by the original activity map
axis image % In case your crop somehow didn't end up being a square?
axis off % To look pretty
shg
