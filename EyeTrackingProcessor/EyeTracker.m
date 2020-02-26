classdef EyeTracker < handle

	properties (Constant = true)
        EYE_RADIUS = 1.7; % mm
        STD_THRESH = 1;
    end
    
    properties
    	movie
    	cropped_movie uint8
    	eye_roi
    	center_of_gaze
    	clean_method
    	pix_per_mm


    	pupil struct
    	center_pt
    end
    
    methods
    	function obj = EyeTracker()
    	end

    	function readEyeTrackingVideo(obj)
    		fprintf('Load your eyetracking video...\n')
            % Load your video
            video_fn = uigetfile('.avi');
            v = VideoReader(video_fn);
            
            %Load movie
            ct=1;
            while hasFrame(v)
                obj.movie(:,:,ct) = imresize(rgb2gray(readFrame(v)), 0.5); %so we can store it as a string...
                ct = ct + 1;
            end
            obj.movie = uint8(obj.movie);
        end
        
        function cleanVideo(obj, method)
            % method has "drop" or "interpolate"
            if nargin < 2 || isempty(method)
            	method = 'drop';
            end
            fprintf('Cleaning video based on the %s method...\n', method)
            obj.clean_method = method; % Just to store
            mean_frame_F = squeeze(mean(mean(obj.movie, 1), 2));
            is_dropped_frame = mean_frame_F == 0;
            switch method
            case 'drop'
            	obj.movie = obj.movie(:, :, ~is_dropped_frame);
            case 'interpolate'
            	for frame = find(is_dropped_frame)'
                    previous_frame = find(~is_dropped_frame(1:frame - 1), 1, 'last'); % previous undropped frame
                    next_frame = find(~is_dropped_frame(frame + 1:end), 1, 'first') + frame; % next undropped frame

                    obj.movie(:, :, frame) = (mean(cat(3, obj.movie(:, :, previous_frame), obj.movie(:, :, next_frame)), 3));
                end
            end
        end


        function cropMovie(obj, method, rotate_flag)
        	if nargin < 2 || isempty(method)
        		method = 'Rectangle';
        	end

        	if nargin < 3 || isempty(rotate_flag)
        		rotate_flag = 0;
        	end

        	obj.getEyeROI(method, rotate_flag);
        	x_size = find(sum(obj.eye_roi), 1, 'last') - find(sum(obj.eye_roi), 1, 'first') + 1;
        	y_size = find(sum(obj.eye_roi, 2), 1, 'last') - find(sum(obj.eye_roi, 2), 1, 'first') + 1;

        	fprintf('Cropping movie to specified ROI...\n')
        	movie_roi = zeros(y_size, x_size, size(obj.movie, 3));
        	ct = 1;
        	for frame = 1:size(obj.movie, 3)
        		curr_frame = obj.movie(:, :, frame);
        		movie_roi(:, :, ct) = reshape(curr_frame(obj.eye_roi), y_size, x_size);
        		ct = ct + 1;
        	end

        	obj.cropped_movie = movie_roi;
        end

        function frame = detectPupil(obj)
            %threshold to find pupil
            % this code assumes that the pupil is the darkest.. can make this better later on
            fprintf('Detecting pupil...\n')
            for frame = 1:size(obj.cropped_movie, 3)
            	is_pupil = obj.cropped_movie(:, :, frame) < (min(min(obj.cropped_movie(:, :, frame))) + ...
                    obj.STD_THRESH*uint8(std(std(single(obj.cropped_movie(:, :, frame)))))); % 1SD brighter
                processed_pupil = bwmorph(is_pupil, 'close'); % clean up the other dark parts
                temp = regionprops(processed_pupil,...
                	'Centroid', 'Orientation', 'BoundingBox', 'MajorAxisLength', 'MinorAxisLength', 'Area', 'Eccentricity');
                if frame == 1
                	idx = obj.pupilChooser(temp);
                else
                    if length(temp) > 1 % more than one region left
                    	idx = obj.determineActualPupil(temp, pupil);
                        % [~, idx] = max([temp.Area]);
                    else
                    	idx = 1;
                    end
                end
                pupil(frame) = temp(idx);
            end
            obj.pupil = pupil; % assignment issues if it's directly done above
        end
        
        function calibrate(obj)
        	cal_img = questdlg('Do you have a calibration image?', 'Calibration', 'Yes', 'No', 'Yes');
        	switch cal_img
        	case 'Yes'
        		disp('Choose your calibration image...')
        		[fn, pn] = uigetfile('*.tif');
        		raw_img = imread([pn, fn]);
		       	% Match resolution
		       	figure;
	           	calibration_img = rgb2gray(raw_img(:, :, 1:3)); % Discard alpha
	           	calibration_img = imresize(calibration_img, [size(obj.movie, 1), size(obj.movie, 2)]);
	           	imagesc(calibration_img);
	           	colormap gray
	           	calibration_line = imline;
	           	distance = pdist(calibration_line.getPosition(), 'euclidean');
	            obj.pix_per_mm = distance / 10; % 10mm per cm
	        case 'No'
	        	warning('No calibration means you shouldn''t really trust the CoG calculation... using a guessed value')
	        	obj.pix_per_mm = 9.17; 
	        end

            obj.getEyeCtr();
        end

        function getEyeCtr(obj)
            % plotting x position against eccentricity
            for frame = 1:numel(obj.pupil)
            	x_pos(frame) = obj.pupil(frame).Centroid(1);
            	y_pos(frame) = obj.pupil(frame).Centroid(2);
            	ecc(frame) = obj.pupil(frame).Eccentricity;
            end

            % Least eccentric
            obj.center_pt(1) = mean(x_pos(ecc < prctile(ecc, 0.1)));
            obj.center_pt(2) = mean(y_pos(ecc < prctile(ecc, 0.1)));
        end
        
        function eye_radius = convertEyeRadiusToPixels(obj, eyeball_info)
            % This is terrible, rn. We need a mm to pix conversion.. how do that?
            if isempty(obj.pix_per_mm)
            	avg_length = mean([eyeball_info.MajorAxisLength, eyeball_info.MinorAxisLength]);
            	eye_radius = avg_length/2;
            else
            	eye_radius = obj.EYE_RADIUS * obj.pix_per_mm;
            end
        end
        
        function [horz_ang, vert_ang] = calculateCoG(obj)
        	imagesc(mean(obj.cropped_movie, 3));
        	colormap gray
        	axis image
        	axis off

        	eyeball = impoly();
        	eyeball_mask = eyeball.createMask();
        	eyeball_info = regionprops(eyeball_mask, 'Centroid', 'MajorAxisLength', 'MinorAxisLength');
        	close

        	for frame = 1:length(obj.pupil)
        		x_centroid(frame) = obj.pupil(frame).Centroid(1);
        		y_centroid(frame) = obj.pupil(frame).Centroid(2);
        	end

        	x_center = mean(x_centroid);
        	y_center = mean(y_centroid);
        	eye_radius = obj.convertEyeRadiusToPixels(eyeball_info);


        	for frame = 1:length(obj.pupil)
        		x_deviation = (x_center - obj.pupil(frame).Centroid(1));
        		h = sqrt(eye_radius ^ 2 - x_deviation ^ 2);
        		y = sqrt(x_deviation^2 + (eye_radius - h)^2);
        		horz_ang(frame) = 2 * asind(y / (2 * eye_radius));
                horz_ang(frame) = horz_ang(frame) * sign(x_deviation); % to account for negative displacements
                
                y_deviation = (y_center - obj.pupil(frame).Centroid(2));
                h = sqrt(eye_radius ^ 2 - y_deviation ^ 2);
                y = sqrt(y_deviation^2 + (eye_radius - h)^2);
                vert_ang(frame) = 2 * asind(y / (2 * eye_radius));
                vert_ang(frame) = vert_ang(frame) * sign(y_deviation);
            end
            % Here we need to subtract the mean, because we initially determined that the "x_center" is the most centered of the pupil, due to eccentricity, this is the correction we added earlier...
            obj.center_of_gaze = [real(vert_ang); real(horz_ang)]; % Some imaginaries for some reason? idk
            for ii = 1:2
            	obj.center_of_gaze(ii, :) = obj.center_of_gaze(ii, :) - mean(obj.center_of_gaze(ii, :));
            end
        end
        
        function gaze_map = getGazeMap(obj)
        	gaze_map = zeros(100, 130);
        	half_pt = size(gaze_map)/2;
        	bound = @(x, l, u) min(max(x, l), u);
        	for y = obj.center_of_gaze
        		curr = zeros(size(gaze_map));
        		curr(bound(half_pt(1) + round(y(1)), 1, size(gaze_map, 1)), bound(half_pt(2) + round(y(2)), 1, size(gaze_map, 2))) = 1;
        		gaze_map = gaze_map + curr;
        	end
        end

        function video = checkPerformance(obj, frames, playback_speed)
        	if nargin < 2 || isempty(frames)
        		frames = 1:size(obj.cropped_movie, 3);
        	end

        	if nargin < 3 || isempty(playback_speed)
                playback_speed = 2; % times
            end

            if isempty(obj.center_of_gaze)
            	video = obj.checkRawPerformance(frames, playback_speed);
            else
            	video = obj.checkCoGPerformance(frames, playback_speed);
            end
        end
    end

    methods (Access = protected)

    	function drawCoG(obj, frame)
    		persistent blank_screen mid_pt im_col im_row
    		if frame == 1
    			im_size  =  [100, 130];
    			blank_screen = zeros(im_size);
    			mid_pt = size(blank_screen) / 2;
    			[im_col, im_row] = meshgrid(1:im_size(1), 1:im_size(2));
    		else
    			blank_screen = blank_screen .* 0.85;
    		end

    		blank_screen(mid_pt(1) - round(obj.center_of_gaze(1, frame)), mid_pt(2) - round(obj.center_of_gaze(2, frame))) = 1;
    		imagesc(fliplr(blank_screen))        
    	end

    	function idx = pupilChooser(obj, temp)
    		figure
    		imagesc(obj.cropped_movie(:, :, 1));
    		title('Choose center of pupil with mouse, hit Enter key when finished')
    		colormap gray
    		axis image
    		axis off
            [x, y] = getpts(); % flipped, not sure if this is right, have Tyler check
            close
            
            candidates = zeros(1, length(temp));
            for ii = 1:length(temp)
            	candidates(ii) = pdist2([x, y], temp(ii).Centroid);
            end
            [~, idx] = min(candidates);
        end
        
        function idx = determineActualPupil(obj, current_pupil, working_pupil)
            %previous pupil positions
            candidate_distance = zeros(1, length(current_pupil));
            candidate_majoraxis = zeros(1, length(current_pupil));
            candidate_minoraxis = zeros(1, length(current_pupil));
            candidate_area = zeros(1, length(current_pupil));

            num_prev_frames = length(working_pupil);
            running_avg = 5;
            if num_prev_frames > running_avg              %if we have more than 5 frames to work with, take the averages as working values
            	for ff = 1:running_avg
                    centroid_vals(ff, :) = working_pupil(num_prev_frames-ff).Centroid;       %idk how to vectorize this such that referencing the Centroid fields outputs all 5 values at once
                    majoraxis_vals(ff) = working_pupil(num_prev_frames-ff).MajorAxisLength;
                    minoraxis_vals(ff) = working_pupil(num_prev_frames-ff).MinorAxisLength;
                    area_vals(ff) = working_pupil(num_prev_frames-ff).Area;
                end
                working_centroid = mean(centroid_vals, 1);
                working_majoraxis = mean(majoraxis_vals);
                working_minoraxis = mean(minoraxis_vals);
                working_area = mean(area_vals);
            else
                working_centroid = working_pupil(end).Centroid;     %if not, use the last values
                working_majoraxis = working_pupil(end).MajorAxisLength;
                working_minoraxis = working_pupil(end).MinorAxisLength;
                working_area = working_pupil(end).Area;
            end
            for ii = 1:length(current_pupil)
                candidate_distance(ii) = pdist2(current_pupil(ii).Centroid, working_centroid);      %first term: distance from centroid candidates to working centroid
                candidate_majoraxis(ii) = abs(current_pupil(ii).MajorAxisLength - working_majoraxis);    %second term: difference between majoraxis lengths and working majoraxis length
                candidate_minoraxis(ii) = abs(current_pupil(ii).MinorAxisLength - working_minoraxis);    %third term: difference between minoraxis lengths and working minoraxis length
                candidate_area(ii) = abs(current_pupil(ii).Area - working_area);                        %fourth term: difference between area and working area
            end
            %Weighted sum of all three values to score each candidate
            a = 0.7;      %distance weight
            b = 0.1;    %major axis weight
            c = 0.1;   %minor axis weight
            d = 0.1;    %area weight
            for ii = 1:length(current_pupil)
            	candidate_score(ii) = a*candidate_distance(ii) + b*candidate_majoraxis(ii) + c*candidate_minoraxis(ii) + d*candidate_area(ii);
            end
            [~, idx] = min(candidate_score);        %lowest score wins
        end
        
        function drawMeasurementText(obj, frame)
            % calculate positions
            bounds = size(obj.cropped_movie);
            pupil_position =  obj.pupil(frame).Centroid;
            pupil_size = obj.pupil(frame).Area;
            
            text(bounds(2) - 60, bounds(1) - 10, ...
            	sprintf('Pupil size: %0.2f', pupil_size),...
            	'Color', 'red',...
            	'FontSize', 12)
            text(bounds(2) - 60, bounds(1) - 5, ...
            	sprintf('Pupil position: [%0.2f, %0.2f]', pupil_position(1), pupil_position(2)),...
            	'Color', 'red',...
            	'FontSize', 12)
        end
        
        function drawPupilBoundary(obj, frame)
        	hold on
        	theta = 0 : 0.01 : 2*pi;
        	x = obj.pupil(frame).MinorAxisLength/2 * cos(theta);
        	y = obj.pupil(frame).MajorAxisLength/2 * sin(theta);

            % rotation?
            ori = obj.pupil(frame).Orientation;
            R = [cosd(ori), -sind(ori);... % create rotation matrix
            sind(ori), cosd(ori)];
            
            rCoords = R * [x; y]; % apply transform
            
            xr = rCoords(1, :)';
            yr = rCoords(2, :)';
            
            plot(yr + obj.pupil(frame).Centroid(1), xr+obj.pupil(frame).Centroid(2), 'LineWidth', 3, 'Color', [1, 0, 0]);
            hold off
        end
        
        function getEyeROI(obj, method, rotate_flag)

        	if rotate_flag
        		figure
        		imagesc(mean(obj.movie, 3));
        		title('Draw a line along the major axis of the eye...')
        		axis off
        		axis image
        		colormap gray
        		rotation_line = imline;
        		line_pts = rotation_line.getPosition();
        		line_length = pdist(line_pts, 'euclidean');
        		horz_length = line_pts(2, 1) - line_pts(1, 1);
        		offset = acosd(horz_length/line_length);
        		for frame = 1:size(obj.movie, 3)
        			obj.movie(:, :, frame) = imrotate(obj.movie(:, :, frame), -offset, 'nearest', 'crop');
        		end
        		close
        	end

        	switch method
        	case 'Rectangle' 
        		fprintf('Choose your bounding box for the mouse eye...\n')
        		figure
        		imagesc(mean(obj.movie, 3));
        		title('Use mouse to drag a rectangle over the mouse eye')
        		axis off
        		axis image
        		colormap gray
        		eye_rectangle = imrect();
        		obj.eye_roi = eye_rectangle.createMask();
        		close
        	case 'Points'
        		fprintf('Select points representing boundaries...\n')
        		figure
        		imagesc(mean(obj.movie, 3));
        		title('Use mouse to select points, press Enter when done')
        		axis off
        		axis image
        		colormap gray
        		[x, y] = getpts();

        		coords = [floor(x) floor(y)];
        		leftmost = min(coords(:, 1));
        		rightmost = max(coords(:, 1));
        		topmost = min(coords(:, 2));
        		bottommost = max(coords(:, 2));
        		x_size = rightmost - leftmost;
        		y_size = bottommost - topmost;
        		movie_mask = zeros(size(obj.movie, 1), size(obj.movie, 2));
        		movie_mask(topmost:topmost+y_size, leftmost:leftmost+x_size) = 1;
        		obj.eye_roi = logical(movie_mask);

        		close
        	end
        end

        function video = checkRawPerformance(obj, frames, playback_speed)
            % Preparing some stuff to set the axis limits
            pupil_size = [obj.pupil(frames).Area];
            
            ct = 1;
            for frame = frames
            	pupil_position(ct, :) = obj.pupil(frame).Centroid;
            	ct = ct  + 1;
            end
            
            pupil_eccentricity = [obj.pupil(frames).Eccentricity];
            
            % Instantiate figure and prepare axes
            figure('Units', 'normalized', 'Position', [0.2750 0.02 0.5 0.7])
            
            tick_values = floor(linspace(1, length(frames), 7));
            
            % preparing all the axes, probably a better way to do this.. but oh well
            subplot(4, 3, 3)
            pupil_size_line = animatedline;
            axis([1, length(frames), minmax(pupil_size)]);
            ylabel('pupil size')
            xticks(tick_values)
            xticklabels(frames(tick_values))
            grid on
            
            subplot(4, 3, 6)
            pupil_eccentricity_line = animatedline;
            axis([1, length(frames), minmax(pupil_eccentricity)]);
            ylabel('pupil eccentricity')            % pupil x tracking
            xticks(tick_values)
            xticklabels(frames(tick_values))
            grid on
            
            subplot(4, 3, 9)
            pupil_x = animatedline;
            axis([1, length(frames), minmax(pupil_position(2, :))]);
            ylabel('x position')
            xticks(tick_values)
            xticklabels(frames(tick_values))
            grid on
            
            % pupil y tracking
            subplot(4, 3, 12)
            pupil_y = animatedline;
            axis([1, length(frames), minmax(pupil_position(1, :))]);
            ylabel('y position')
            xticks(tick_values)
            xticklabels(frames(tick_values))
            xlabel('frame #')
            grid on
            
            frame_ctr = 1;
            for frame = frames
            	subplot(4, 3, [1:2, 4:5])
                image(obj.cropped_movie(:, :, frame) * (64/255)) % scaling factor to get it in the right range
                colormap gray
                axis off
                axis image
                title(sprintf('Frame # %d', frame))
                obj.drawPupilBoundary(frame);
                %obj.drawMeasurementText(frame);
                %freezeColors();
                
                
                addpoints(pupil_size_line, frame_ctr, obj.pupil(frame).Area);
                addpoints(pupil_eccentricity_line, frame_ctr, obj.pupil(frame).Eccentricity);
                addpoints(pupil_x, frame_ctr, obj.pupil(frame).Centroid(2));
                addpoints(pupil_y, frame_ctr, obj.pupil(frame).Centroid(1));
                frame_ctr = frame_ctr + 1;
                pause(1/(30 * playback_speed))
                
                video(frame_ctr) = getframe(gcf);
            end
        end

        function video = checkCoGPerformance(obj, frames, playback_speed)
            % Preparing some stuff to set the axis limits
            pupil_size = [obj.pupil(frames).Area];
            
            ct = 1;
            for frame = frames
            	pupil_position(ct, :) = obj.pupil(frame).Centroid;
            	ct = ct  + 1;
            end
            
            pupil_eccentricity = [obj.pupil(frames).Eccentricity];
            
            % Instantiate figure and prepare axes
            figure('Units', 'normalized', 'Position', [0.2750 0.02 0.5 0.7])
            
            tick_values = floor(linspace(1, length(frames), 7));
            
            % preparing all the axes, probably a better way to do this.. but oh well
            subplot(4, 3, 3)
            pupil_size_line = animatedline;
            axis([1, length(frames), minmax(pupil_size)]);
            ylabel('pupil size')
            xticks(tick_values)
            xticklabels(frames(tick_values))
            grid on
            
            subplot(4, 3, 6)
            pupil_eccentricity_line = animatedline;
            axis([1, length(frames), minmax(pupil_eccentricity)]);
            ylabel('pupil eccentricity')            % pupil x tracking
            xticks(tick_values)
            xticklabels(frames(tick_values))
            grid on
            
            subplot(4, 3, 9)
            pupil_x = animatedline;
            axis([1, length(frames), minmax(obj.center_of_gaze(2, :))]);
            ylabel('x position')
            xticks(tick_values)
            xticklabels(frames(tick_values))
            grid on
            
            % pupil y tracking
            subplot(4, 3, 12)
            pupil_y = animatedline;
            axis([1, length(frames), minmax(obj.center_of_gaze(1, :))]);
            ylabel('y position')
            xticks(tick_values)
            xticklabels(frames(tick_values))
            xlabel('frame #')
            grid on
            
            frame_ctr = 1;
            for frame = frames
            	subplot(4, 3, [1:2, 4:5])
                image(obj.cropped_movie(:, :, frame) * (64/255)) % scaling factor to get it in the right range
                colormap gray
                axis off
                axis image
                title(sprintf('Frame # %d', frame))
                obj.drawPupilBoundary(frame);
                %obj.drawMeasurementText(frame);
                %freezeColors();
                
                subplot(4, 3, [7:8, 10:11]);
                obj.drawCoG(frame);
                colormap(bone)
                
                addpoints(pupil_size_line, frame_ctr, obj.pupil(frame).Area);
                addpoints(pupil_eccentricity_line, frame_ctr, obj.pupil(frame).Eccentricity);
                addpoints(pupil_x, frame_ctr, obj.center_of_gaze(2, frame));
                addpoints(pupil_y, frame_ctr, obj.center_of_gaze(1, frame));
                frame_ctr = frame_ctr + 1;
                pause(1/(30 * playback_speed))
                
                video(frame_ctr) = getframe(gcf);
            end
        end
    end
end