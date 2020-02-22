% This master script is for running the rotacage v2 in the standard experimental control paradigm

clear

%% Set parameters
big_diameter = 256; % mm
small_diameter =  37.81; % mm

rotations = 300; % seconds of rotation? or rotations per repeat?

offset = 45; % 45 degree offset from previous

repeats = 5;

rpm = 3; % speed of the platform

%% Initialize objects
% Array of stepper motors
motors = StepperMotor({'port0/line0', 'port0/line1', 'port0/line4', 'port0/line5', 'port0/line6'});
motors(2) = StepperMotor({'port0/line2', 'port0/line3', 'port1/line1', 'port1/line2', 'port1/line3'});

s = StepperController(motors); % pass the array of stepper motors in, and generate the clock inside


scaleRPM = @(x) (big_diameter * x) / small_diameter; % for calculating rpm


% Set directions first
for m = 1:length(motors)
	s.changeDirection('cw', m); % set the direction of the motors
end

for rep = 1:repeats
	s.queue([3, scaleRPM(3)], 'seconds', rotations); % rotate both platform and visual cues for the predetermined number of seconds
	s.rotate(2, offset); % offset the visual cues by 45 degrees... is there some kind of scaling that needs to happen here? probably.. how can we scale the offset?
end