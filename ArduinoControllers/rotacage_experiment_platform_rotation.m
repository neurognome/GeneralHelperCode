% set up arduinos
% Both pins are generally D7.
% COM 4 is the port closer to the screen
clear
addpath(genpath('./_Classes'));
s = ArduinoDCMotorController([], 'COM4');
s.addMotor(2);

led = ArduinoLEDController(s.getArduinoPointer(), [], {'D6'}); % Pass the arduino pointer into here

% start experiment


% duration = 20;%25; % minutes
n_repeats = 3; 
params = [120, 5]; % seconds on, seconds off

total_duration = sum(params)* 2 * n_repeats; 
% n_repeats = ceil(duration / (sum(params) * 1/60));
led.on()

fprintf('Experiment duration: %ds\n', total_duration)
disp('Press any key to continue...')
pause

spd = 0.16;
for r = 1:n_repeats
    fprintf('Repeat #%d\n', r)
    
    disp('Light on...')
    led.on()
    
    disp('Forward...')
    s.rotate(spd) % Default 0.7
    pause(params(1))
    
    disp('Stop...')
    s.stop()
    pause(params(2))
    
    disp('Light off...')
    led.off()
    
    disp('Forward...')
    s.rotate(spd) % Default 0.7
    pause(params(1))
    
    disp('Stop...')
    s.stop()
    pause(params(2))
end

disp('Finished!')