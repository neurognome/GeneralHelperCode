%nidaq_testing_script

% Gonna need a controller
% LED? IDK
% Stepper for sure
t = StepperController({'port0/line0','port0/line1','port0/line2','port0/line3','port0/line4'});
t(2) = StepperController({'port1/line1','port1/line2','port1/line3','port1/line4','port1/line5'});


t(1).setMicrostepAmount('Eighth')
t(2).setMicrostepAmount('Quarter')

duration = 0.3;
for ii = 1:20000
    t(1).step();    
    t(2).step();
    java.lang.Thread.sleep(duration);
    
end