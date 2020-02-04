%nidaq_testing_script

% Gonna need a controller
% LED? IDK
% Stepper for sure
addpath(genpath('./_Classes'))
m = MicrostepperControl({'port0/line4', 'port0/line5', 'port0/line6'});
t = StepperController({'port0/line0','port0/line1'}, m);
%t = StepperController({'port1/line1','port1/line2','port1/line3','port1/line4','port1/line5'});

t.queue(300, 'steps', 200);
t.drive()

t.test(40); % should be 1 full rotation