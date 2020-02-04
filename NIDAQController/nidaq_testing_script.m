%nidaq_testing_script

% Gonna need a controller
% LED? IDK
% Stepper for sure
addpath(genpath('./_Classes'))
m = MicrostepDriver({'port0/line4', 'port0/line5', 'port0/line6'});
s = StepperDriver({'port0/line0','port0/line1'}, m);
s(2) = StepperDriver({'port0/line2', 'port0/line3'}, m);

s(2).drive();
s(1).test(40); % should be 1 full rotation
s(2).test(40);

clear('m', 't')