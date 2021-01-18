classdef ArduinoDCMotorController < ArduinoController
% This should be pretty simple because it's based on the existing Adafruit MotorshieldV2 library

properties
    dcm_ptr
end

methods
    function obj = ArduinoDCMotorController(ptr, port)
        if nargin < 1 || isempty(ptr)
            ptr = [];
        end

        if nargin < 2 || isempty(port)
            port = [];
        end

        obj = obj@ArduinoController(ptr, port);

        shield = addon(obj.arduino_ptr, 'Adafruit\MotorShieldV2');
        addrs = scanI2CBus(obj.arduino_ptr, 0);
        obj.dcm_ptr = dcmotor(shield, 2);
    end

    function rotate(obj, speed)
        if nargin < 2 || isempty(speed);
            speed = 0.5; %half max
        end
        obj.dcm_ptr.Speed = speed;

        start(obj.dcm_ptr);
    end

    function stop(obj)
        stop(obj.dcm_ptr);
    end
end
end