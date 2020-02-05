addpath(genpath('_Classes'));
clear

m = StepperMotor({'port0/line0', 'port0/line1', 'port0/line4', 'port0/line5', 'port0/line6'});
t = Clock();

temp = StepperController(m, t);

temp.changeMicrostep('Half');
temp.test(100)