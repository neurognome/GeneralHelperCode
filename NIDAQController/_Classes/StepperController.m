classdef StepperController < NIDAQController
	properties (Constant = true)
		STEPS_PER_REV = 200;
		MAX_SPEED = 400;
	end

	properties
		motors
		step_idx

		aux_controller
		timer
	end

	methods
		function obj = StepperController(motors, timer, aux_controller)
			obj = obj@NIDAQController();
			obj.motors = motors;
			obj.aux_controller = aux_controller; % I don't like this...
			obj.timer = timer;

			% Add lines
			ct = 1;
			for m = obj.motors
				obj.step_idx(ct) = obj.addDigitalOutput(m.getStepLine());
				ct = ct + 1;
			end

			% Set up time
			obj.session.addClockConnection('External',['Dev1/' obj.timer.getClockTerminal()], 'ScanClock');
			obj.session.Rate = obj.timer.getFs();
			obj.timer.startClock();
		end

		function queue(obj, speed, input_type, value)
			if strcmp(input_type, 'steps') && (length(speed) ~= length(obj.motors) || length(value) ~= length(obj.motors))
				error('Input the same number of speed/values as motors');
			end
            % Queue output data, this lets us set up a stimilus trial structure by queueing multiple "phases"
            obj.checkSpeed(max(speed))

            switch input_type
            	% Duration must be equal, but spee might not be
            case 'steps'
            	n_steps = value .* obj.aux_controller.getMicrostepScale();

            	for n = 1:length(obj.motors)
            		duration(n) = obj.getDuration(n_steps(n), speed(n));
            	end

            	if all(duration == duration(1))
            		duration = duration(1);
            	else
            		error('Different directions calculated, check your numbers')
            	end

            case 'seconds'
            	duration = value;
            	n_steps = obj.getSteps(duration, speed);
            end

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

	    function drive(obj)
            % Start driving motor
            obj.session.startBackground();
        end

        function lockDrive(obj)
        	obj.session.startForeground();
        end

        function test(obj, speed)
            % For quick testing
            obj.queue(repmat(speed, 1, length(obj.motors)), 'steps', repmat(200, 1, length(obj.motors))); % should be 1 rev
            obj.drive();

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
            speed = speed .* obj.aux_controller.getMicrostepScale();
            duration = n_steps .* 1./((speed./ 60) .* obj.STEPS_PER_REV); % nsteps * rotations per second * 1/steps per rotation
        end

        function n_steps = getSteps(obj, duration, speed)
            % Convert from speed and duration to number steps
            speed = speed .* obj.aux_controller.getMicrostepScale();
            n_steps = (speed./60) .* duration .* obj.STEPS_PER_REV .* obj.aux_controller.getMicrostepScale();
        end
    end
end


