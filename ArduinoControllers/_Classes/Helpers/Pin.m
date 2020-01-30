classdef Pin < handle
    properties
        pin_id
        pin_number % If we never use the pin number and "signal type" get rid of em
        pin_type
        signal_type
        arduino_ptr
        value = 0;
    end
    
    methods
        function obj = Pin(pin_ID, arduino_ptr)
            obj.parsePinID(pin_ID);
            obj.pin_id = pin_ID;
            obj.arduino_ptr = arduino_ptr;
        end
        
        function parsePinID(obj, pin_ID)
            obj.pin_number = str2double(pin_ID(2));
            switch pin_ID(1)
                case 'A'
                    obj.signal_type = 'analog';
                case 'D'
                    obj.signal_type = 'digital';
                    obj.arduino_ptr.configurePin(obj.pin_id, 'DigitalOutput')
            end
        end
        
        % Setters and Getters
        function out = getPinID(obj)
            out = obj.pin_id;
        end
        
        function out = getSignalType(obj)
            out = obj.signal_type;
        end
        
        function out = getPinType(obj)
            out = obj.pin_type;
        end
        
        function out = getPinNumber(obj)
            out = obj.pin_number;
        end
        
        function out = getPinValue(obj)
            out = obj.value;
        end
        
        function obj = setPinValue(obj, val)
            obj.value = val;
        end
    end
end