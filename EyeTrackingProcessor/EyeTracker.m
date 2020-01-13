classdef EyeTracker < handle
    properties
        movie
        cropped_movie
        eye_roi
        clean_method
        
        pupil struct
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
                ct=ct+1;
            end
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
                        
                        obj.movie(:, :, frame) = uint8(mean(cat(3, obj.movie(:, :, previous_frame), obj.movie(:, :, next_frame)), 3));
                    end
            end
        end
        
        function cropMovie(obj)
            obj.getEyeROI();
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
        
        function detectPupil(obj)
            %threshold to find pupil
            % this code assumes that the pupil is the darkest.. can make this better later on
            fprintf('Detecting pupil...\n')
            for frame = 1:size(obj.cropped_movie, 3)
                is_pupil = obj.cropped_movie(:, :, frame) < 3 * min(min(obj.cropped_movie(:, :, frame)));
                processed_pupil = bwmorph(is_pupil, 'open'); % clean up the other dark parts
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
        
        function checkPerformance(obj, frames, playback_speed)
            if nargin < 2 || isempty(frames)
                frames = 1:size(obj.cropped_movie, 3);
            end
            
            if nargin < 3 || isempty(playback_speed)
                playback_speed = 2; % times
            end
            
            % Preparing some stuff to set the axis limits
            pupil_size = [obj.pupil(frames).Area];
            
            ct = 1;
            for frame = frames
                pupil_position(ct, :) = obj.pupil(frame).Centroid;
                ct = ct  + 1;
            end
            
            pupil_eccentricity = [obj.pupil(frames).Eccentricity];
            
            % Instantiate figure and prepare axes
            figure('Units', 'normalized', 'Position', [0.2750 0.02 0.45 0.9])
            
            tick_values = floor(linspace(1, length(frames), 7));
            
            % preparing all the axes, probably a better way to do this.. but oh well
            subplot(5, 2, 7)
            pupil_size_line = animatedline;
            axis([1, length(frames), minmax(pupil_size)]);
            ylabel('pupil size')
            xticks(tick_values)
            xticklabels(frames(tick_values))
            grid on
            
            subplot(5, 2, 9)
            pupil_eccentricity_line = animatedline;
            axis([1, length(frames), minmax(pupil_eccentricity)]);
            ylabel('pupil eccentricity')            % pupil x tracking
            xticks(tick_values)
            xticklabels(frames(tick_values))
            grid on
            
            subplot(5, 2, 8)
            pupil_x = animatedline;
            axis([1, length(frames), minmax(pupil_position(:, 1)')]);
            ylabel('x position')
            xticks(tick_values)
            xticklabels(frames(tick_values))
            grid on
            
            % pupil y tracking
            subplot(5, 2, 10)
            pupil_y = animatedline;
            axis([1, length(frames), minmax(pupil_position(:, 2)')]);
            ylabel('y position')
            xticks(tick_values)
            xticklabels(frames(tick_values))
            xlabel('frame #')
            grid on
            
            frame_ctr = 1;
            for frame = frames
                subplot(5, 2, 1:6)
                image(obj.cropped_movie(:, :, frame) * (64/255)) % scaling factor to get it in the right range
                colormap gray
                axis off
                axis image
                title(sprintf('Frame # %d', frame))
                obj.drawPupilBoundary(frame);
                %obj.drawMeasurementText(frame);
                
                addpoints(pupil_size_line, frame_ctr, obj.pupil(frame).Area);
                addpoints(pupil_eccentricity_line, frame_ctr, obj.pupil(frame).Eccentricity);
                addpoints(pupil_x, frame_ctr, obj.pupil(frame).Centroid(1));
                addpoints(pupil_y, frame_ctr, obj.pupil(frame).Centroid(2));
                frame_ctr = frame_ctr + 1;
                pause(1/(30 * playback_speed))
            end
        end
    end
    
    methods (Access = protected)
        function idx = pupilChooser(obj, temp)
            figure
            imagesc(obj.cropped_movie(:, :, 1));
            title('Choose center of pupil with mouse, hit Enter key when finished')
            colormap gray
            axis image
            axis off
            [x, y] = getpts();
            close
            
            candidates = zeros(1, length(temp));
            for ii = 1:length(temp)
                candidates(ii) = pdist2([x, y], temp(ii).Centroid);
            end
            [~, idx] = min(candidates);
            
        end
        
        function idx = determineActualPupil(obj, current_pupil, working_pupil)
            %previous pupil positions
            candidates = zeros(1, length(current_pupil));
            for ii = 1:length(current_pupil)
                candidates(ii) = pdist2(current_pupil(ii).Centroid, working_pupil(end).Centroid);
            end
            [~, idx] = min(candidates);
            % additional checks... later
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
            %    xCenter = 12.5;
            %   yCenter = 10;
            %  xRadius = 2.5;
            % yRadius = 8;
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
        
        function getEyeROI(obj)
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
        end
    end
    
end