%nidaq_testing_script

% Gonna need a controller
% LED? IDK
% Stepper for sure
addpath(genpath('./_Classes'))
m = MicrostepperDriver({'port0/line4', 'port0/line5', 'port0/line6'});
t = SteppreDriver({'port0/line0','port0/line1'});
t(2) = StepperDriver({'port0/line2', 'port0/line3'});

% 
 t(1).queue(10, 'steps', 200);
 t(2).queue(10, 'steps', 200);
 t(1).drive();
t(2).drive();
t(1).test(40); % should be 1 full rotation
t(2).test(40);

clear('m', 't')