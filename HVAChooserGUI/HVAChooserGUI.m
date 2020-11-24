classdef HVAChooserGUI < handle
	properties (Access = protected)
		f % figure
		ax % main axes
		im % main image

		roi_choices_list
		status_msg
		maps

		overlay
		poly
		roi_struct = struct();
	end

	properties
		working = true;
	end

	methods
		function obj = HVAChooserGUI(maps)
			obj.maps = maps;
			obj.overlay = false(size(obj.maps.VFS_raw));
			obj.f = figure('Visible', 'off', 'Units', 'normalized', 'Position', [0.125, 0.125, 0.75, 0.75], 'CloseRequestFcn', @obj.closeFigure);

			obj.ax = axes('Position', [-0.1, 0.1, 0.8, 0.8]);

            uipanel('Position', [0.65 0.35 0.3 0.55]); % defaults to normalized

            % Create select button
            select_button = uicontrol('Style', 'pushbutton', 'Units', 'normalized');
            select_button.String = 'Add';
            select_button.Position = [0.7, 0.4, 0.2, 0.1];
            select_button.FontSize = 20;
            select_button.Callback = @obj.selectButtonCallback;

			% Create clear button
			clear_button = uicontrol('Style', 'pushbutton', 'Units', 'normalized');
			clear_button.String = 'Clear';
			clear_button.Position = [0.7, 0.5, 0.2, 0.05];
			clear_button.FontSize = 20;
			clear_button.Callback = @obj.clearButtonCallback;

			% Create finished button
			finished_button = uicontrol('Style', 'pushbutton', 'Units', 'normalized');
			finished_button.String = 'Finished';
			finished_button.Position = [0.7, 0.2, 0.2, 0.1];
			finished_button.FontSize = 20;
			finished_button.BackgroundColor = [0, 1, 0];
			finished_button.Callback = @obj.finishedButtonCallback;

    		% Get list of roi choices
    		obj.roi_choices_list = uicontrol('Style', 'popupmenu', 'Units', 'normalized');
    		obj.roi_choices_list.Position = [0.7, 0.75, 0.2, 0.1];
    		obj.roi_choices_list.FontSize = 20;
    		obj.roi_choices_list.String = {'V1', 'LM', 'PM', 'AL', 'LI', 'RL', 'AM', 'S1', 'VC'}; % change this

            % Create status message
            obj.status_msg = uicontrol('Style', 'text', 'Units', 'normalized');
            obj.status_msg.Position = [0.1, 0.025, 0.4, 0.05];
            obj.status_msg.BackgroundColor = [1, 1, 1];
            obj.status_msg.FontSize = 15;

            obj.f.Visible = 'on';

            % Main loop
            obj.msg('Draw ROI...')
            obj.update();
        end

        function out = getFigureHandle(obj)
        	out = obj.f;
        end

        function replotOverlay(obj)
        	imagesc(obj.ax, obj.overlay, 'alphadata', double(obj.overlay) * 0.5);
        	axis off
        	axis square
        	colormap jet
        end

        function msg(obj, msg)
        	obj.status_msg.String = msg;
        end

        function clearButtonCallback(obj, ~, ~)
        	obj.poly.delete();
        	obj.msg('Cleared polygon')
        	obj.update();
        end

        function closeFigure(obj, ~, ~) % runs twice for some reason?
        	obj.working = false;
        	obj.saveROIs();
        	pause(1)
        	delete(obj.f);
        end
        
        function saveROIs(obj)
        	assignin('base', 'rois', obj.roi_struct);
        	obj.msg('Output rois to base workspace as ''rois''');
        end
        
        function update(obj)
        	obj.im = imagesc(obj.ax, obj.maps.VFS_raw);
        	hold on
        	imagesc(obj.ax, obj.overlay, 'alphadata', double(obj.overlay) * 0.5);
        	axis off
        	axis square
        	colormap jet
        	hold off
        	obj.drawROI();
        end

        function finishedButtonCallback(obj, ~, ~)
        	obj.working = false;
        	obj.closeFigure();
        end

        function selectButtonCallback(obj, ~, ~)
        	value = obj.roi_choices_list.Value;
        	roi_name = obj.roi_choices_list.String{value};
        	obj.roi_struct.(roi_name) = obj.poly.createMask(obj.im);
        	obj.poly.delete();

        	obj.updateOverlay();
        	obj.msg(sprintf('Added %s to output structure. \n', roi_name))
        	obj.update();
        end

        function updateOverlay(obj)
        	overlay = false(size(obj.maps.VFS_raw));
        	for f = fieldnames(obj.roi_struct)'
        		overlay = overlay + obj.roi_struct.(f{:});
        	end 
        	obj.overlay = logical(overlay);
        end

        function drawROI(obj)
        	obj.poly = drawpolygon();
        end
    end
end