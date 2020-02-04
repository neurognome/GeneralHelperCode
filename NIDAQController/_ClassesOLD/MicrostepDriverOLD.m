classdef MicrostepDriver < NIDAQDriver
	properties
		microstep_lines 
		microstep_value
        direction_line
	end

	methods
		function obj = MicrostepDriver(lines)
			obj = obj@NIDAQDriver()

			if nargin < 1 || isempty(lines)
				lines = obj.inputPorts({'direction', 'microstep1', 'microstep2', 'microstep3'});
			end

            obj.direction_line = obj.addDigitalOutput(lines{1});
			for i_line = 1:3
				obj.microstep_lines(i_line) = obj.addDigitalOutput(lines{i_line+1});
			end
			obj.output = zeros(1, length(obj.microstep_lines));
			obj.setMicrostepAmount('Sixteenth');
		end

		function setMicrostepAmount(obj, microstep_amount)
			if nargin < 2 || isempty(microstep_amount)
                % Stupid MATLAB doesn't let us have more than 3 buttons...
                choices = {'Full', 'Half', 'Quarter', 'Eighth', 'Sixteenth'};
                val = listdlg('PromptString', 'Choose microstep amount:',... 
                	'ListString',choices, 'SelectionMode', 'single');
                microstep_amount = choices{val};
            end
            switch microstep_amount
            case 'Full'
            	obj.digitalWrite(obj.microstep_lines(1), 0);
            	obj.digitalWrite(obj.microstep_lines(2), 0);
            	obj.digitalWrite(obj.microstep_lines(3), 0);
            case 'Half'
            	obj.digitalWrite(obj.microstep_lines(1), 1);
            	obj.digitalWrite(obj.microstep_lines(2), 0);
            	obj.digitalWrite(obj.microstep_lines(3), 0);
            case 'Quarter'
            	obj.digitalWrite(obj.microstep_lines(1), 0);
            	obj.digitalWrite(obj.microstep_lines(2), 1);
            	obj.digitalWrite(obj.microstep_lines(3), 0);
            case 'Eighth'
            	obj.digitalWrite(obj.microstep_lines(1), 1);
            	obj.digitalWrite(obj.microstep_lines(2), 1);
            	obj.digitalWrite(obj.microstep_lines(3), 0);
            case 'Sixteenth'
            	obj.digitalWrite(obj.microstep_lines(1), 1);
            	obj.digitalWrite(obj.microstep_lines(2), 1);
            	obj.digitalWrite(obj.microstep_lines(3), 1);
            end
            
            obj.microstep_value = microstep_amount;
        end

        function out = getMicrostepScale(obj)
        	switch obj.microstep_value
        	case 'Full'
        		out = 1;
        	case 'Half'
        		out = 2;
        	case 'Quarter'
        		out = 4;
        	case 'Eighth'
        		out = 8
        	case 'Sixteenth'
        		out = 16;
        	end
        end

        
    end
end
