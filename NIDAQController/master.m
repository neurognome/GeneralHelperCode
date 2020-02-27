clear
m = StepperMotor({'port0/line0', 'port0/line1', 'port0/line4', 'port0/line5', 'port0/line6'});
m(2) = StepperMotor({'port0/line2', 'port0/line3', 'port1/line1', 'port1/line2', 'port1/line3'});

temp = StepperController(m);

% Experimental structure
temp.queue([100, 200], 'seconds', 1);
temp.queue([400, 0], 'seconds', 2);
temp.wait(2);
temp.rotate(2, 90);%temp.queue([0, 50], 'steps', [0, 50]); % why switch no work? % add queue flushing, add pause
temp.wait(2); %temp.queue([0, 0], 'seconds', 1);
temp.queue([100, 150], 'seconds', 5);
temp.drive();


% Whenever you change direction, microstep, you need to give it a break in the drive. This is because the auxiliary
% controller works through different lines than the main driver, and can't be queued into the output

big_dia = 256; %mm
small_dia = 37.81; %mm
scaleRPM = @(x) (big_dia * x) / small_dia;

% Rotate
temp.changeDirection(1, 'cw');
temp.changeDirection(2, 'cw');
temp.queue([3, scaleRPM(3)], 'steps', 100);
temp.drive()

pause(1);

% Offset
temp.changeDirection(1, 'cw');
temp.rotate(1, 45);
temp.drive()
pause(1);

% Reset
temp.changeDirection(1, 'ccw');
temp.rotate(1, 45);
temp.drive()

pause(1);

% Rotate
temp.changeDirection(1, 'cw');
temp.queue([3, 20], 'seconds', 5);
temp.drive();

