classdef ArduinoDCMotorController < ArduinoController
% This should be pretty simple because it's based on the existing Adafruit MotorshieldV2 library

properties
    dcm_ptr
    shield_ptr
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

        obj.shield_ptr = addon(obj.arduino_ptr, 'Adafruit\MotorShieldV2');
        % addrs = scanI2CBus(obj.arduino_ptr, motor_id);
        % obj.dcm_ptr = dcmotor(shield, motor_id);
    end

    function addMotor(obj, motor_id)
        if isempty(obj.dcm_ptr)
            obj.dcm_ptr = dcmotor(obj.shield_ptr, motor_id);
        else
            obj.dcm_ptr(end+1) = dcmotor(obj.shield_ptr, motor_id);
        end
    end

    function rotate(obj, speed, motor_id)
        if nargin < 2 || isempty(speed);
            speed = 0.5; %half max
        end
        if nargin < 3 || isempty(motor_id)
            motor_id = 1;
        end
        obj.dcm_ptr(motor_id).Speed = speed;

        start(obj.dcm_ptr(motor_id));
    end

    function stop(obj, motor_id)
        if nargin < 2 || isempty(motor_id)
            motor_id = 1:length(obj.dcm_ptr);
        end
        for m = motor_id
            stop(obj.dcm_ptr(m));
        end
    end
end
end