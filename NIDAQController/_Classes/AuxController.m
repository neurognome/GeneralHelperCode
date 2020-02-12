classdef AuxController < NIDAQController
	properties
		dir_idx
		microstep_idx

		microstep_value
		motor

	end

	methods
		function obj = AuxController(motor)
			obj = obj@NIDAQController();
			obj.motor = motor;

			obj.dir_idx = obj.addDigitalOutput(obj.motor.getDirLine());
			for l = 1:3
				obj.microstep_idx(l) = obj.addDigitalOutput(obj.motor.getMicrostepLine(l));
			end
			obj.output = zeros(1, 4);
			obj.setMicrostep('Sixteenth')
		end

		function setMicrostep(obj, microstep_amount)
			if nargin < 2 || isempty(microstep_amount)
                % Stupid MATLAB doesn't let us have more than 3 buttons...
                choices = {'Full', 'Half', 'Quarter', 'Eighth', 'Sixteenth'};
                val = listdlg('PromptString', 'Choose microstep amount:',... 
                	'ListString',choices, 'SelectionMode', 'single');
                microstep_amount = choices{val};
            end
            switch microstep_amount
            case 'Full'
            	obj.digitalWrite(obj.microstep_idx(1), 0);
            	obj.digitalWrite(obj.microstep_idx(2), 0);
            	obj.digitalWrite(obj.microstep_idx(3), 0);
            case 'Half'
            	obj.digitalWrite(obj.microstep_idx(1), 1);
            	obj.digitalWrite(obj.microstep_idx(2), 0);
            	obj.digitalWrite(obj.microstep_idx(3), 0);
            case 'Quarter'
            	obj.digitalWrite(obj.microstep_idx(1), 0);
            	obj.digitalWrite(obj.microstep_idx(2), 1);
            	obj.digitalWrite(obj.microstep_idx(3), 0);
            case 'Eighth'
            	obj.digitalWrite(obj.microstep_idx(1), 1);
            	obj.digitalWrite(obj.microstep_idx(2), 1);
            	obj.digitalWrite(obj.microstep_idx(3), 0);
            case 'Sixteenth'
            	obj.digitalWrite(obj.microstep_idx(1), 1);
            	obj.digitalWrite(obj.microstep_idx(2), 1);
            	obj.digitalWrite(obj.microstep_idx(3), 1);
            otherwise
                error('Wrong value, choices: Full, Half, Quarter, Eighth, Sixteenth')
            end
            
            obj.microstep_value = microstep_amount;
        end

        function setDirection(obj, direction)
        	switch direction
        	case 'cw'
        		obj.digitalWrite(obj.dir_idx, 0);
        	case 'ccw'
        		obj.digitalWrite(obj.dir_idx, 1);
        	end
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
