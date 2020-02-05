classdef NIDAQDriver < handle
	properties
	end

	methods
		function obj = NIDAQDriver()
		end
		
		function lines = inputPorts(obj, needed_lines)
            % Get and format lines properly for the NIDAQ
            base_str = 'Input line for %s:';
            dialog_request{1} = sprintf('Input shared port:');
            for ii = 1:length(needed_lines)
            	dialog_request{ii + 1} = sprintf(base_str, needed_lines{ii});
            end
            line_numbers = inputdlg(dialog_request');
            for ii = 2:length(line_numbers)
            	lines{ii-1} = sprintf('port%s/line%s', line_numbers{1}, line_numbers{ii});
            end
        end
    end

end