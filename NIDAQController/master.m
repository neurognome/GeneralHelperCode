clear
m = StepperMotor({'port0/line0', 'port0/line1', 'port0/line4', 'port0/line5', 'port0/line6'});
m(2) = StepperMotor({'port0/line2', 'port0/line3', 'port1/line1', 'port1/line2', 'port1/line3'});
t = Clock();

temp = StepperController(m, t);

% Experimental structure
temp.queue([100, 200], 'seconds', 1);
temp.queue([400, 0], 'seconds', 2);
temp.wait(2);
temp.rotate(2, 90);%temp.queue([0, 50], 'steps', [0, 50]); % why switch no work? % add queue flushing, add pause
temp.wait(2); %temp.queue([0, 0], 'seconds', 1);
temp.queue([100, 150], 'seconds', 5);
temp.drive();


temp.queue([3, 10], 'seconds', 10);
temp.rotate(1, 90);
temp.queue([3, 10], 'seconds', 10);
temp.drive();

temp.t(100)