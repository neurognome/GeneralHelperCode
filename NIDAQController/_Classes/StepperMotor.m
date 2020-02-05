classdef StepperMotor < NIDAQDriver
	properties
		step_line
		dir_line
		microstep_lines

		state
	end
	methods
		function obj = StepperMotor(lines)
			if nargin < 1 || isempty(lines)
				lines = obj.inputPorts({'step', 'direction'});
			end
			obj.step_line = lines{1};
			obj.dir_line = lines{2};
			obj.microstep_lines = lines(3:end);
			obj.state = zeros(1, length(lines));
		end

		function out = getStepLine(obj)
			out = obj.step_line;
		end

		function out = getDirLine(obj)
			out = obj.dir_line;
		end

		function out = getMicrostepLine(obj, n)
			if nargin < 2 || isempty(n)
				out = obj.microstep_lines;
			else
				out = obj.microstep_lines{n};
			end
		end

		function out = getState(obj)
			out = obj.state;
		end
	end
end
