%nidaq_testing_script

% Gonna need a controller
% LED? IDK
% Stepper for sure
addpath(genpath('./_Classes'))
t = StepperController({'port0/line0','port0/line1','port0/line2','port0/line3','port0/line4'});
%t(2) = StepperController({'port1/line1','port1/line2','port1/line3','port1/line4','port1/line5'});


t(1).setMicrostepAmount('Full')
%t(2).setMicrostepAmount('Full')

duration = 0.05;
for ii = 1:20000
    t(1).step();    
    java.lang.Thread.sleep(0);
 %   t(2).step();
end