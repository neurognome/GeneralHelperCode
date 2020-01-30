classdef ArduinoLEDController < ArduinoController
    properties
        pin WritePin
    end
    
    methods
        function obj = ArduinoLEDController(port, pin)
            if nargin < 1 || isempty(port)
                port = [];
            end
            
            obj = obj@ArduinoController(port);
            
            if nargin < 2 || isempty(pin)
                pin = obj.inputPins('light control');
            end
            
            obj.pin = WritePin(pin{1}, obj.arduino_ptr);
        end
        
        function on(obj)
            obj.pin.setValue(1);
        end
        
        function off(obj)
            obj.pin.setValue(0);
        end  
    end
end
