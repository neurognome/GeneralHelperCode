% set up arduinos
% Both pins are generally D7.
% COM 4 is the port closer to the screen

addpath(genpath('./_Classes'));
s = ArduinoServoController([], 'COM9');

led = ArduinoLEDController([], 'COM8'); % Pass the arduino pointer into here

% start experiment


% duration = 20;%25; % minutes
n_repeats = 5; 
params = [120, 10]; % seconds on, seconds off

total_duration = sum(params)* 4 * n_repeats; 
% n_repeats = ceil(duration / (sum(params) * 1/60));
led.on()

fprintf('Experiment duration: %ds\n', n_repeats * sum(params))
disp('Press any key to continue...')
pause

for r = 1:n_repeats
    fprintf('Repeat #%d\n', r)
    
    disp('Light on...')
    led.on()
    
    s.rotate(0.05, 'forward') % Default 0.7
    pause(params(1))
       
    s.stop()
    pause(params(2))
    
    s.rotate(0.05, 'backward')
    pause(params(1))
    
    s.stop()
    pause(params(2))
    
    disp('Light off...')
    led.off()
    
    s.rotate(0.05, 'forward') % Default 0.7
    pause(params(1))
       
    s.stop()
    pause(params(2))
    
    s.rotate(0.05, 'backward')
    pause(params(1))
    
    s.stop()
    pause(params(2)) 
end

disp('Finished!')