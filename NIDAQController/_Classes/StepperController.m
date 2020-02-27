classdef StepperController < NIDAQController
	properties (Constant = true)
		MAX_SPEED = 400;
        STEPS_PER_REV = 200;
    end

    properties
        motors
        step_idx

        aux_controller
        clock
    end

    methods
      function obj = StepperController(motors)
         obj = obj@NIDAQController();
         obj.motors = motors;
         obj.clock = Clock();

			% Add lines
			ct = 1;
			for m = obj.motors
				obj.step_idx(ct) = obj.addDigitalOutput(m.getStepLine());
				if ct == 1
					obj.aux_controller = AuxController(m);
				else
					obj.aux_controller(ct) = AuxController(m);
				end
				ct = ct + 1;
			end

			% Set up time
			obj.session.addClockConnection('External',['Dev1/' obj.clock.getClockTerminal()], 'ScanClock');
			obj.session.Rate = obj.clock.getFs();
			obj.clock.startClock();
		end

		function queue(obj, speed, input_type, value)
			if strcmp(input_type, 'steps') && (length(speed) ~= length(obj.motors) || length(value) ~= length(obj.motors))
				%error('Input the same number of speed/values as motors');
                value = repmat(value, 1, length(obj.motors));
            end

            norm = min(speed); % idk why we need this right now, but it's to normalize the speeds to get proper scaling

            obj.checkSpeed(max(speed))

            switch input_type
            case 'steps'
                for n = 1:length(obj.motors)
                    n_steps(n) = (value(n) .* obj.aux_controller(n).getMicrostepScale() * speed(n))/norm;
                end
                duration = obj.getDuration(n_steps(1), speed(1));
            case 'seconds'
                duration = value;
                for n = 1:length(obj.motors)
                    n_steps = obj.getSteps(duration, speed(n) * obj.aux_controller(n).getMicrostepScale());
                end
            end


            % When steps are 0, then time is 0, get rid of these errors
            duration(isnan(duration)) = 0;
            duration = max(duration);

	        n_samples = round(duration .* obj.session.Rate); % Getting the length of the output vector
	        output = zeros(n_samples, length(obj.motors));
	        for n = 1:length(obj.motors)
	        	step_vec = round(linspace(1, n_samples - 1, n_steps(n)));
	        	drive_vector = false(1, n_samples);
	        	drive_vector(step_vec) = true;
	        	output(:, n) = drive_vector;
	        end
	        obj.sendDataToDAQ(output);
	    end

	    function flush(obj)
	    	obj.session.release();
	    end

	    function wait(obj, duration)
	    	obj.queue(zeros(1, length(obj.motors)), 'seconds', duration);
	    end

	    function rotate(obj, motor_num, angle, speed)
	    	if nargin < 4 || isempty(speed)
	    		speed = 10;
	    	end
	    	speeds = zeros(1, length(obj.motors));
	    	steps = speeds;
	    	speeds(motor_num) = speed;
	    	steps(motor_num) = round((angle/360) * 200);
	    	obj.queue(speeds, 'steps', steps)
	    end

	    function drive(obj)
            % Start driving motor
            obj.session.startForeground();
        end

        function backgroundDrive(obj)
        	obj.session.startBackground();
        end

        function abort(obj)
        	obj.session.stop();
        	obj.flush();
        end
        
        function test(obj, speed)
            % For quick testing
            obj.queue(repmat(speed, 1, length(obj.motors)), 'steps', repmat(200, 1, length(obj.motors))); % should be 1 rev
            obj.drive();
        end

        function changeDirection(obj, motor_num, direction)
        	if nargin < 2 || isempty(direction)
        		direction = questdlg('Choose your direction: ', 'Direction', 'cw', 'ccw', 'cw');
        	end

        	if nargin < 3 || isempty(motor_num)
        		motor_num = 1;
        	end

        	obj.aux_controller(motor_num).setDirection(direction)
        end

        function changeMicrostep(obj, motor_num, microstep)
        	if nargin  < 3 || isempty(motor_num)
        		motor_num = 1;
        	end

        	obj.aux_controller(motor_num).setMicrostep(microstep);
        end
    end

    methods (Access = protected)
    	function checkSpeed(obj, speed)
            % Ensure speed isn't too high
            if speed > obj.MAX_SPEED
            	error('Speed is too high, limited to 400RPM')
            end
        end

        function sendDataToDAQ(obj, data)
        	obj.session.queueOutputData(data);
        end

        function duration = getDuration(obj, n_steps, speed) 
            % Convert from n_steps and speed to time (in seconds)
            duration = (n_steps/(obj.STEPS_PER_REV * obj.aux_controller(1).getMicrostepScale())) * (60/speed); % to account for microstepping
        end

        function n_steps = getSteps(obj, duration, speed)
            % Convert from speed and duration to number steps
            n_steps = (speed./60) .* duration .* (obj.STEPS_PER_REV * obj.aux_controller(1).getMicrostepScale());
        end
    end
end


