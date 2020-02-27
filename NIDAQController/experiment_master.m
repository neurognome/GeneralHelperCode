% This master script is for running the rotacage v2 in the standard experimental control paradigm

clear

%% Set parameters
big_diameter = 256; % mm
small_diameter =  37.81; % mm

t_rotation = 300; % seconds of rotation? or t_rotation per repeat?

offset = 30	; % 45 degree offset from previous

repeats = 5;

rpm = 3; % speed of the platform

fprintf('Total stimulus duration: ')
%% Initialize objects
% Array of stepper motors
motors = StepperMotor({'port0/line0', 'port0/line1', 'port0/line4', 'port0/line5', 'port0/line6'});
motors(2) = StepperMotor({'port0/line2', 'port0/line3', 'port1/line1', 'port1/line2', 'port1/line3'});

s = StepperController(motors); % pass the array of stepper motors in, and generate the clock inside

% Convert from time to steps for easier logging
s_rotations = t_rotation / (rpm / 60); % number of rotations
s_offset = offset / 2; % number of steps to offset, because 2 degree steps each...


scaleRPM = @(x) (big_diameter * x) / small_diameter; % for calculating rpm

% Set directions first
for m = 1:length(motors)
	s.changeDirection('cw', m); % set the direction of the motors
end

for rep = 1:repeats
	s.queue([3, scaleRPM(3)], 'steps', s_rotations); % rotate both platform and visual cues for the predetermined number of seconds
	s.rotate([0, scaleRPM(3), 'steps', s_offset]); % rotate 15 steps, aka 30 degrees, b/c 2 step per degree
	% s.rotate(2, offset); % offset the visual cues by 45 degrees... is there some kind of scaling that needs to happen here? probably.. how can we scale the offset?
end

% Generate the position vector
