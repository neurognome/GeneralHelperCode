% set up arduinos


s = ArduinoServoController();

led = ArduinoLEDController(s.arduino_ptr); % Pass the arduino pointer into here

% start experiment


duration = 25; % minutes

params = [135, 15] % seconds on, seconds off

n_repeats = duration / (sum(params) * 1/60);

for r = 1:n_repeats
    disp('Rotating...')
    s.rotate(0.05) % Default 0.7
    pause(params(1))
    
    disp('Halting...')
    s.stop()
    pause(params(2))

    if mod(r, 2)
    	led.switch();
    end
end

disp('Finished!')