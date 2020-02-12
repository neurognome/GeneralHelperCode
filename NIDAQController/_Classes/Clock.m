classdef Clock < handle
    properties (Constant = true)
        CLOCK_FREQ = 1e5;
    end

    properties
      clock_session
      terminal
  end

  methods
      function obj = Clock()
            % From https://www.mathworks.com/help/daq/acquire-digital-data-using-a-counter-output-channel-as-external-clock.html

            obj.clock_session = daq.createSession('ni');
            ch = addCounterOutputChannel(obj.clock_session,'Dev1', 0, 'PulseGeneration');
            ch.Frequency = obj.CLOCK_FREQ;
            obj.terminal = ch.Terminal;
            obj.clock_session.IsContinuous = true;
            obj.clock_session.Rate = ch.Frequency;
            % obj.session.addClockConnection('External',['Dev1/' clk_terminal], 'ScanClock');
        end

        function out = getClockTerminal(obj)
        	out = obj.terminal;
        end

        function startClock(obj)
        	obj.clock_session.startBackground();

            for ii = 1:10 % Confirm the clock is running
            	if obj.clock_session.IsRunning
            		break;
            	else
            		pause(0.1);
            	end
            end   
        end

        function out = getFs(obj)
        	out = obj.CLOCK_FREQ;
        end
    end
end
