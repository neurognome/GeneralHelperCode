classdef StepperController < NIDAQController
	properties (Constant = true)
		STEPS_PER_REV = 200;
		MAX_SPEED = 400;
	end

	properties
		motors
		step_idx

		aux_controller
		clock
	end

	methods
		function obj = StepperController(motors, clock)
			obj = obj@NIDAQController();
			obj.motors = motors;
			%obj.aux_controller = aux_controller; % I don't like this...
			obj.clock = clock;

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
				error('Input the same number of speed/values as motors');
			end

            % Queue output data, this lets us set up a stimilus trial structure by queueing multiple "phases"
            obj.checkSpeed(max(speed))
            for n = 1:length(obj.motors)
            	switch input_type
            	case 'steps'
            		n_steps(n) = value(n) .* obj.aux_controller(n).getMicrostepScale();
            		duration(n) = obj.getDuration(n_steps(n), speed(n) * obj.aux_controller(n).getMicrostepScale());
            	case 'seconds'
            		duration(n) = value;
            		n_steps = obj.getSteps(duration, speed * obj.aux_controller(n).getMicrostepScale());
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

        function changeDirection(obj, direction, motor_num)
        	if nargin < 2 || isempty(direction)
        		direction = questdlg('Choose your direction: ', 'Direction', 'cw', 'ccw', 'cw');
        	end

        	if nargin < 3 || isempty(motor_num)
        		motor_num = 1;
        	end

        	obj.aux_controller(motor_num).setDirection(direction)
        end

        function changeMicrostep(obj, microstep, motor_num)
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
            %speed = speed .;
            duration = n_steps .* 1./((speed./ 60) .* obj.STEPS_PER_REV); % nsteps * rotations per second * 1/steps per rotation
        end

        function n_steps = getSteps(obj, duration, speed)
            % Convert from speed and duration to number steps
           % speed = speed .* obj.aux_controller.getMicrostepScale();
           n_steps = (speed./60) .* duration .* obj.STEPS_PER_REV;
       end
   end
end


