classdef ArduinoLEDController < ArduinoController
    properties
        pin WritePin
    end
    
    methods
        function obj = ArduinoLEDController(ptr, port, pin)
            if nargin < 1 || isempty(ptr)
                ptr = [];
            end
            if nargin < 2 || isempty(port)
                port = [];
            end
            
            obj = obj@ArduinoController(ptr, port);
            
            if nargin < 3 || isempty(pin)
                pin = obj.inputPins({'light control'});
            end
            
            obj.pin = WritePin(pin{1}, obj.arduino_ptr);
        end
        
        function on(obj)
            obj.pin.setValue(1);
        end
        
        function off(obj)
            obj.pin.setValue(0);
        end  

        function light_switch(obj)
            if obj.pin.getPinValue() == 1
                obj.off();
            else
                obj.on();
            end
        end
    end
end