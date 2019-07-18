function exampleFieldPlotter()
%% Written 16Jul2019 KS

% This function lets you plot an average projection map (in grayscale), and overlay the activity map over it, with proper
% scaling of the activity. It uses the activity map to define transparency, with more active cells being less transparent
% allowing the "base color map" to come through more. Black areas are floored to 0, so that they don't miscolor the image

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setting everything up
gain = 1.5; % This gain value helps to bring the cells out more... if you can't really see your cells, adjust this.

% Choosing data file, could add later an input data file
fprintf('Choose your data file... \n')
datafile = matfile(uigetfile('*.mat'));

% Select a color for the activity map
fprintf('Choose a color for your activity map... \n')
activity_map_color = uisetcolor;

% Extract activity and average projection maps from the data file, the constructions prevents loading of the entire file
fprintf('Loading your data...\n')
avg_projection = getfield(datafile,'data','avg_projection');
activity_map   = getfield(datafile,'data','activity_map');

% Sometimes cropping makes the activity map look better...
crop_flag = questdlg('Do you want to crop your image?','Crop choice','Yes','No','No');

if strcmp(crop_flag,'Yes')
    fprintf('Choose your crop area, double click when finished...  \n')
    imagesc(avg_projection) % Show the map and adjust
    axis square
    axis off
    colormap gray
    
    h = imrect(gca,[200,200,400,400]); % Create a 400x400 rectangle roughly centered as an roi
    setFixedAspectRatioMode(h,true); % Restrict the rectangle to be only a square
    fcn = makeConstrainToRectFcn('imrect',get(gca,'XLim'),get(gca,'YLim')); % Don't let the edges of the rectangle go outside the image
    setPositionConstraintFcn(h,fcn);
    shg
   
    wait(h); % Wait until the ROI is double clicked before progressing
    
    crop = round(h.getPosition); % Get the position of the roi, in [x_min, y_min, x_size, y_size]
    
    close % Now that we have everything we need, get rid of the thing
    
    crop = round([crop(2):crop(2)+crop(4)-1;... % This converts it from start value and size to the correct idx
                  crop(1):crop(1)+crop(3)-1]);
    
    avg_projection = avg_projection(crop(1,:),crop(2,:)); % Crop using defined indices above
    activity_map   = activity_map(crop(1,:),crop(2,:));
    
end

%% Setting up the maps for display
transparency_map = rescale(activity_map); % First bringing everything to [0,1]
transparency_map(transparency_map <= prctile(transparency_map(:),80)) = 0; % Floor lower values to avoid color cast, non-cells affected only        

transparency_map = transparency_map * gain;
transparency_map(transparency_map > 1) = 0.90; % keep a little transparency regardless, so it doesn't block out the avg_projection


%% Display the plots

figure
image(rescale(avg_projection(:,:,[1 1 1]))); % show the average projection, converted to RGB for compatibility
hold on
colormap gray

h = image(cat(3,ones(size(avg_projection)).*activity_map_color(1),...  % This construction is making the "base color map" in RGB
                ones(size(avg_projection)).*activity_map_color(2),...
                ones(size(avg_projection)).*activity_map_color(3))); 

set(h,'AlphaData',transparency_map); % Set the transparency of the base color map to the transparency defined by the original activity map

axis image % In case your crop somehow didn't end up being a square?
axis off % To look pretty
shg
