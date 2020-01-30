classdef ArduinoController < handle
    properties
        arduino_ptr
    end
    methods
        function obj = Controller(arduino_ptr, arduino_port)
            addpath('./Helpers') % Make sure these are included
            if nargin < 1 || ~isempty(arduino_ptr)
            	obj.arduino_ptr = arduino_ptr;
            else
	            if nargin < 2 || isempty(arduino_port)
	                obj.arduino_ptr = arduino();
	            else
	                obj.arduino_ptr = arduino(arduino_port);
	            end
	        end
        end
        
        function pins = inputPins(obj, needed_pins)
            % Sets input pins if not provided
            base_str = 'Input %s pin: ';
            
            for ii = 1:length(needed_pins)
                dialog_request{ii} = sprintf(base_str, needed_pins{ii});
            end
            pins = inputdlg(dialog_request);
        end
        
        function report(obj)
            % Generates a simple report of the used pins and their current values
            ct = 1;
            for p = properties(obj)'
                s_classes = superclasses(obj.(p{1}));
                if any(strcmp(s_classes, 'Pin'))
                    for ii = 1:length(obj.(p{1}))
                        pin_name{ct} = p{1};
                        pin_type{ct} = obj.(p{1})(ii).getPinType();
                        pin_id{ct} = obj.(p{1})(ii).getPinID();
                        pin_value{ct} = obj.(p{1})(ii).getPinValue();
                        signal_type{ct} = obj.(p{1})(ii).getSignalType();
                        ct = ct + 1;
                    end
                end
            end
            output_table = table(pin_name', pin_type', signal_type', pin_id', pin_value',...
                'VariableNames', {'Name' ,'PinType', 'SignalType','PinID', 'PinValue'});
            disp(output_table)
        end
        
    end
end
