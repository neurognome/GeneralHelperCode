classdef PWMPin < WritePin
    properties
    end
    methods
        function obj = PWMPin(pin_id, arduino_ptr)
            obj = obj@WritePin(pin_id, arduino_ptr);
            if strcmp(obj.signal_type, 'analog')
                error('PWM pins cannot be analog')
            end
        end

        function obj = setValue(obj, val)
            obj.setPinValue(val);
            obj.arduino_ptr.writePWMDutyCycle(obj.pin_id, val);
        end
    end
end