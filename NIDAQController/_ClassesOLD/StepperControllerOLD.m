classdef StepperController < handle 
	properties
		stepper_driver
		microstepper_driver
		timer
	end

	methods
		function obj = StepperController(stepper_drivers, timer)
			obj.stepper_driver = stepper_drivers;
			obj.timer = timer;
		end

		function initialize(obj)
			obj.timer.startClock();
			ct = 1;
			for s = obj.stepper_driver
				s.session.addClockConnection('External',['Dev1/' obj.timer.terminal{1}], 'ScanClock');
				s.session.Rate = obj.timer.getFs();
				ct = ct + 1;
			end
		end
		
		function test(obj)
			for s = obj.stepper_driver
				s.queue(10, 'steps', 200)
			end

			for s = obj.stepper_driver
				s.drive();
			end
		end
	end
end