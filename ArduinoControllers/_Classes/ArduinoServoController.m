classdef ArduinoServoController < ArduinoController
    
    % Updated to new framework, not sure if it's gonna work 29Jan2020
    
    % Simple class for controlling continuously rotating servos for the floting cage
    % It's definitely not linear, but we can figure this out later
    % Written 11Nov2019 KS
    
    properties (Constant = true)
        MAX_FORWARD = 0.8;
        MAX_BACKWARD = 0.3;
        MIN_STOP = 0.45;
        MAX_STOP = 0.513;
        SERVO_PIN = 'D4';
        ARDUINO_PORT = 'COM5';
        
        % In microseconds
        MIN_PULSE_DURATION = 700;
        MAX_PULSE_DURATION = 2300;
    end
    
    properties (Access = public)
        arduino_ptr
        servo_ptr
    end
    
    methods (Access = public)
        function obj = ArduinoServoController(ptr, port, servo_pin)
            if nargin < 1 || isempty(ptr)
                ptr = [];
            end

            if nargin < 2 || isempty(port)
                port = [];
            end
            obj = obj@ArduinoController(ptr, port);
            
            if nargin < 3 || isempty(servo_pin)
                servo_pin = obj.inputPins('servo');
            end

            obj.servo_ptr = obj.arduino_ptr.servo(servo_pin,...
                'MinPulseDuration', obj.MIN_PULSE_DURATION * 10^-6,...
                'MaxPulseDuration', obj.MAX_PULSE_DURATION * 10 ^-6);
            obj.stop();
        end
        
        function runExperiment(obj, duration, params)
            if nargin < 2 || isempty(duration)
                duration = 25; % minutes
            end
            
            if nargin < 3 || isempty(params)
                params = [105, 15]; % on seconds, off seconds
            end
            
            n_repeats = duration / (sum(params) * 1/60);
            for r = 1:n_repeats
                disp('Rotating...')
                obj.rotate(0.05) % Default 0.7
                pause(params(1))
                
                disp('Halting...')
                obj.stop()
                pause(params(2))
            end
            
            disp('Finished!')
        end
        
         function habituateMouse(obj, duration, params)
            if nargin < 2 || isempty(duration)
                duration = 20; % minutes
            end
            
            if nargin < 3 || isempty(params)
                params = [10, 10]; % on seconds, off seconds
            end
            
            n_repeats = duration / (sum(params) * 1/60);
            for r = 1:n_repeats
                disp('Rotating...')
                if mod(r, 2)
                obj.rotate(0.06) % Default 0.7
                else
                    obj.rotate(0.05, 'backward')
                end
                pause(params(1))
                
                disp('Halting...')
                obj.stop()
                pause(params(2))
            end
            
            disp('Finished!')
        end
        
        function stop(obj)
            obj.servo_ptr.writePosition((obj.MIN_STOP + obj.MAX_STOP)/2)
        end
        
        function rotate(obj, speed, direction_flag)
            if nargin < 2 || isempty(speed)
                speed = 0.1; % percent of maximum speed
            end
            
            if nargin < 3 || isempty(direction_flag)
                direction_flag = 'forward'; % or 'backward'
            end
            
            obj.servo_ptr.writePosition(obj.convertFromSpeed(speed, direction_flag))
        end
    end
    
    methods (Access = protected)
        function out = convertFromSpeed(obj, speed, direction_flag)
            switch direction_flag
                case 'forward'
                    out = obj.MAX_STOP + (min([speed, 1])) * (obj.MAX_FORWARD - obj.MAX_STOP);
                case 'backward'
                    out = obj.MIN_STOP - (min([speed, 1])) * (obj.MIN_STOP - obj.MAX_BACKWARD);
            end
        end
    end
end
