classdef ReadPin < Pin
    properties
    end
    methods
        function obj = ReadPin(pin_ID, arduino_ptr)
            obj = obj@Pin(pin_ID, arduino_ptr, 'read');
        end
        
        function val = read(obj)
            % Reads pin value, can work for either
            switch obj.signal_type
                case 'digital'
                    val = obj.arduino_ptr.readDigitalPin(obj.pin_id);
                case 'analog'
                    val = obj.arduino_ptr.readVoltage(obj.pin_id);
            end
            obj.setPinValue(val);
        end
    end
end