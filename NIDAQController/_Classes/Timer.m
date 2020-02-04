classdef Timer < handle
	properties
		clock_session
	end
	
	methods
		function obj = Timer()
            % From https://www.mathworks.com/help/daq/acquire-digital-data-using-a-counter-output-channel-as-external-clock.html

            obj.clock_session = daq.createSession('ni');
            ch1 = addCounterOutputChannel(obj.clock_session,'Dev1', 0, 'PulseGeneration');
            clk_terminal = ch1.Terminal;
            ch1.Frequency = obj.CLOCK_FREQ;
            obj.clock_session.IsContinuous = true;
            obj.session.Rate = ch1.Frequency;
            obj.clock_session.Rate = ch1.Frequency;
            obj.session.addClockConnection('External',['Dev1/' clk_terminal], 'ScanClock');
            obj.clock_session.startBackground();

            for ii = 1:10 % Confirm the clock is running
                if obj.clock_session.IsRunning
                    break;
                else
                    pause(0.1);
                end
            end        
        end
		end
	end
end