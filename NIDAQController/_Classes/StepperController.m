classdef StepperController < NIDAQController
    properties (Constant = true)
        STEPS_PER_REV = 200;
    end
    
    properties
        dir_line
        step_line 
        microstep_lines 
        
        microstep_value
    end
    
    methods
        function obj = StepperController(lines)
            
            obj = obj@NIDAQController(10000); % Call superclass constructor
            
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
            java.lang.Thread.sleep(0.001);
            obj.digitalWrite(obj.step_line, 0);
            java.lang.Thread.sleep(0.001);
        end
        
        function setDirection(obj, direction)
            switch direction
                case 'forward'
                    obj.digitalWrite(obj.dir_line, 1);
                case 'backward'
                    obj.digitalWrite(obj.dir_line, 0);
            end
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
        
        % As we develop this class, there's going to need to be a lot of conversions to get from steps to time, etc, while
        % taking into account the microstepping value (make sure to scale it properly).
        
        % We can figure this out!! the DELAY (converted from RPM) will give the # of steps per minute, therefore RPM.
        % Each PULSE is a step, and we change the frequency of these pulses to get RPM!
        
        
    end
    
end