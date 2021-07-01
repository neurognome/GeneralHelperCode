clear
addpath(genpath('./_Classes'));
s = ArduinoDCMotorController([], 'COM3');
s.addMotor(1);
led = ArduinoLEDController(s.getArduinoPointer(), [], {'D6'}); % Pass the arduino pointer into here
led.on()
spd = 0.30;
s.rotate(spd) % Default 0.7

pause
clear
