% set up arduinos

addpath('./_Classes');
s = ArduinoServoController([], 'COM4');

% start experiment
s.habituateMouse();

duration = 20;%25; % minutes

params = [30, 30] % seconds on, seconds off

n_repeats = duration / (sum(params) * 1/60);

disp('Press any key to continue...')
pause

for r = 1:n_repeats
    disp('Rotating...')
    s.rotate(0.05) % Default 0.7
    pause(params(1))
    
    disp('Halting...')
    s.stop()
    pause(params(2))
end

disp('Finished!')