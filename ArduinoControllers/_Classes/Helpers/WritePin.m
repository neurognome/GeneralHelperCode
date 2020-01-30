classdef WritePin < Pin
    properties
    end
    methods
        function obj = WritePin(pin_ID, arduino_ptr)
            obj = obj@Pin(pin_ID, arduino_ptr);
            obj.pin_type = 'write';
        end
        
        function obj = setValue(obj, val)
            % Sets value of pin, only works for digital
            obj.setPinValue(val);
            switch obj.signal_type
                case 'digital'
                    obj.arduino_ptr.writeDigitalPin(obj.pin_id, val); 
                case 'analog'
                    error('Arduino UNO can''t output analog signals');
            end          
        end
    end
end