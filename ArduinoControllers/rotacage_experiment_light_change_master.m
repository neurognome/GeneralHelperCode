% set up arduinos
% Both pins are generally D7.
% COM 4 is the port closer to the screen
clear
addpath(genpath('./_Classes'));
s = ArduinoDCMotorController([], 'COM3');
s.addMotor(2);

led = ArduinoLEDController(s.getArduinoPointer(), [], {'D6'}); % Pass the arduino pointer into here

% start experiment


% light differences
brightness = [0, 2.^[0:6], 100]/100;
n_repeats = 5; 
params = [30, 1]; % seconds on, seconds off

total_duration = sum(params) * n_repeats * length(brightness); 
% n_repeats = ceil(duration / (sum(params) * 1/60));
led.on()

fprintf('Experiment duration: %ds\n', total_duration)
disp('Press any key to continue...')
pause

spd = -0.16;
rand_idx = randperm(length(brightness) - 1);
rand_idx = [length(brightness), rand_idx];

for r = 1:n_repeats
    fprintf('Repeat #%d\n', r)
    for b = rand_idx
        disp('Light on...')
        led.dim(brightness(b))
        
        disp('Forward...')
        s.rotate(spd) % Default 0.7
        pause(params(1))
        
        disp('Stop...')
        s.stop()
        pause(params(2))
    end
end

led.off();

disp('Finished!')

uisave({'rand_idx', 'brightness'}, 'rand_brightness.mat')