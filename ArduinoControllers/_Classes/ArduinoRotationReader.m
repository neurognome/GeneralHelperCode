classdef ArduinoRotationReader < handle
    properties
        serial_obj
        baud_rate = 9600;
        data
    end

    methods
        function obj = ArduinoRotationReader(port)
            obj.serial_obj = serialport(port, obj.baud_rate);
            obj.serial_obj.configureTerminator('CR/LF');
            obj.serial_obj.UserData = struct('Data', []);
        end

        function start(obj)
            obj.serial_obj.flush();
            obj.serial_obj.configureCallback('terminator', @obj.readData)
        end

        function stop(obj)
            configureCallback(obj.serial_obj, 'off')
            obj.data = obj.serial_obj.UserData.Data(2:end);
        end

        function cleanup(obj)
            obj.serial_obj.delete();
            obj.serial_obj = [];
        end

        function s = readData(obj, s, ~)
            data = s.readline();
            s.UserData.Data(end + 1) = str2double(data);
        end
    end
end