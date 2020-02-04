classdef StepperController < NIDAQController
    properties (Constant = true)
        STEPS_PER_REV = 200;
        MAX_SPEED = 400;
        CLOCK_FREQ = 1e6;
    end
    
    properties (Access = protected)
        dir_line
        step_line 
        clock_session
        microstep_controller
    end
    
    methods
        function obj = StepperController(lines, microstep_controller)
            obj = obj@NIDAQController(); % Call superclass constructor
            obj.microstep_controller = microstep_controller;

            % Assign lines
            if nargin < 1 || isempty(lines)
                lines = obj.inputPorts({'step', 'direction', 'microstep1', 'microstep2', 'microstep3'});
            end

            obj.step_line = obj.addDigitalOutput(lines{1});
            obj.dir_line = obj.addDigitalOutput(lines{2});
            obj.output = zeros(1, length(lines));

            obj.setupClock();
        end

        function setDirection(obj, direction)
            % Choose the direction of your stepper motor
            switch direction
            case 'ccw'
                obj.digitalWrite(obj.dir_line, 1);
            case 'cw'
                obj.digitalWrite(obj.dir_line, 0);
            otherwise
                error('Incorrect input (cw or ccw)')
            end
        end

        function queue(obj, speed, input_type, value)
            % Queue output data, this lets us set up a stimilus trial structure by queueing multiple "phases"
            obj.checkSpeed(speed)

            switch input_type
            case 'steps'
                n_steps = value * obj.microstep_controller.getMicrostepScale();
                duration = obj.getDuration(n_steps, speed);
            case 'seconds'
                duration = value;
                n_steps = obj.getSteps(duration, speed);
            end
            n_samples = round(duration .* obj.session.Rate); % Getting the length of the output vector
            step_vec = round(linspace(1, n_samples - 1, n_steps));
            drive_vector = false(1, n_samples);
            % drive_vector(step_vec) = true;
            for ii = 0:0
                drive_vector(step_vec + ii) = true;
            end
            disp(sum(drive_vector))
            plot(drive_vector)
            obj.sendDataToDAQ(drive_vector);
        end


        function drive(obj)
            % Start driving motor
            obj.session.startForeground();
        end

        function test(obj, speed)
            % For quick testing
            obj.queue(speed, 'steps', 200); % should be 1 rev
            obj.drive();
        end
    end

    methods (Access = protected)
         function setupClock(obj)
            % From https://www.mathworks.com/help/daq/acquire-digital-data-using-a-counter-output-channel-as-external-clock.html
            obj.clock_session = daq.createSession('ni');
            ch1 = addCounterOutputChannel(obj.clock_session,'Dev1', 0, 'PulseGeneration');
            clk_terminal = ch1.Terminal;
            ch1.Frequency = obj.CLOCK_FREQ;
            obj.clock_session.IsContinuous = true;
            obj.session.Rate = ch1.Frequency;
            obj.clock_session.Rate = ch1.Frequency;
            obj.session.addClockConnection('External',['Dev1/' clk_terminal], 'ScanClock');
            obj.clock_session.startBackground();

            for ii = 1:10 % Confirm the clock is running
                if obj.clock_session.IsRunning
                    break;
                else
                    pause(0.1);
                end
            end        
        end
        
        function checkSpeed(obj, speed)
            % Ensure speed isn't too high
            if speed > obj.MAX_SPEED
                error('Speed is too high, limited to 400RPM')
            end
        end

        function sendDataToDAQ(obj, data)
            % Query current conditions and send a cohesive output matrix to the DAQ
            is_not_step_line = 1:length(obj.output) ~= obj.step_line;
            output = zeros(length(data), length(obj.output));
            output(:, obj.step_line) = data;
            for ii = find(is_not_step_line)
                output(:, ii) = repmat(obj.output(ii), length(data), 1);
            end
            obj.session.queueOutputData(output);
        end

        function duration = getDuration(obj, n_steps, speed) 
            % Convert from n_steps and speed to time (in seconds)
            speed = speed * obj.microstep_controller.getMicrostepScale();
            duration = n_steps * 1/((speed/60) * obj.STEPS_PER_REV); % nsteps * rotations per second * 1/steps per rotation
        end

        function n_steps = getSteps(obj, duration, speed)
            % Convert from speed and duration to number steps
            speed = speed * obj.microstep_controller.getMicrostepScale();
            n_steps = (speed/60) * duration * obj.STEPS_PER_REV * obj.microstep_controller.getMicrostepScale();
        end
    end
end