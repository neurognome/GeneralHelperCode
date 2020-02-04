classdef StepperController < NIDAQController
    properties (Constant = true)
        STEPS_PER_REV = 200;
        clockFreq = 10000;
    end
    
    properties
        dir_line
        step_line 
        microstep_lines 
        
        microstep_value

        clock_session
    end
    
    methods
        function obj = StepperController(lines)

            obj = obj@NIDAQController(10000); % Call superclass constructor
            % From https://www.mathworks.com/help/daq/acquire-digital-data-using-a-counter-output-channel-as-external-clock.html
            obj.clock_session = daq.createSession('ni');
            ch1 = addCounterOutputChannel(obj.clock_session,'Dev1',0,'PulseGeneration');
            clkTerminal = ch1.Terminal;
            ch1.Frequency = obj.clockFreq;
            obj.clock_session.IsContinuous = true;


            % Assign lines
            if nargin < 1 || isempty(lines)
                lines = obj.inputPorts({'step', 'direction', 'microstep1', 'microstep2', 'microstep3'});
            end

            obj.step_line = obj.addDigitalOutput(lines{1});
            obj.dir_line = obj.addDigitalOutput(lines{2});
            for i_line = 1:3
                obj.microstep_lines(i_line) = obj.addDigitalOutput(lines{i_line+2});
            end
            
            obj.output = zeros(1, length(lines));


            obj.session.addClockConnection('External',['Dev1/' clkTerminal], 'ScanClock');
            obj.clock_session.startBackground();
            
            for i = 1:10 
                if obj.clock_session.IsRunning
                    break;
                else
                    pause(0.1);
                end
            end

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
        
        function step(obj)
            obj.digitalWrite(obj.step_line, 1);
            java.lang.Thread.sleep(0.5);
            obj.digitalWrite(obj.step_line, 0);
            java.lang.Thread.sleep(0.5);
        end
        
        function setDirection(obj, direction)
            switch direction
            case 'forward'
                obj.digitalWrite(obj.dir_line, 1);
            case 'backward'
                obj.digitalWrite(obj.dir_line, 0);
            end
        end

        function queue(obj, duration, speed)
            % Add in checks for the maximum speeds given the fs
            n_samples = round(duration .* obj.session.Rate);
            n_revolutions = (speed/60) * duration; % rps
            n_steps = n_revolutions * 200;
            step_vec = round(linspace(1, n_samples-1, n_steps));
            drive_vector = false(1, n_samples);

            drive_vector(step_vec) = true; % Setting steps in the true portions...
            obj.session.queueOutputData(cat(2, drive_vector', ones(n_samples, 1), zeros(n_samples, 3)));
        end


        function queueSteps(obj, n_steps, speed)
            duration = n_steps * 1/((speed/60) * 200); % nsteps * rotations per second * 1/steps per rotation
            n_samples = round(duration .* obj.session.Rate);
            step_vec = round(linspace(1, n_samples-1, n_steps));
            drive_vector = false(1, n_samples);
            drive_vector(step_vec) = true;
            obj.session.queueOutputData(cat(2, drive_vector', ones(n_samples, 1), zeros(n_samples, 3)));
        end

        function rotate(obj, angle, speed)
            if nargin < 3 || isempty(speed)
                speed = 30;
            end
            n_steps = round((angle/360) .* obj.STEPS_PER_REV);
            disp(n_steps)
            obj.queueSteps(n_steps, speed);
            obj.drive();
        end

        function drive(obj)
            obj.session.startBackground();
        end

        function demo(obj)
            duration = 10;
            tic
            obj.setDirection('backward')
            for x = 1:200
                obj.digitalWrite(obj.step_line, 1);
                java.lang.Thread.sleep(duration);
                obj.digitalWrite(obj.step_line, 0);
                java.lang.Thread.sleep(duration);
            end
            obj.setDirection('forward');
            for x = 1:200
                obj.digitalWrite(obj.step_line, 1);
                java.lang.Thread.sleep(duration);
                obj.digitalWrite(obj.step_line, 0);
                java.lang.Thread.sleep(duration);
            end
            toc
        end

    end
end