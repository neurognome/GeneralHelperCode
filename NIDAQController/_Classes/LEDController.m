classdef LEDController < NIDAQController
    properties
        light_line
    end
    
    methods
        function obj = LEDController(lines)
            % Prepare the controller
            obj = obj@NIDAQController();
            
            if nargin < 1 || isempty(lines)
                lines = obj.inputPorts({'LED control'});
            end
            
            % Set lines
            [obj.light_line] = obj.addDigitalOutput(lines{1});
            
            % Init output
            obj.output = zeros(1, length(lines));
        end
        
        function on(obj)
            obj.digitalWrite(obj.light_line, 1);
            disp('Light on!')
        end
        
        function off(obj)
            obj.digitalWrite(obj.light_line, 0);
            disp('Light off!')
        end
    end
end
