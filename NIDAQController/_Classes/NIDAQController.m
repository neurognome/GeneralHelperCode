classdef NIDAQController < handle
	properties
		session
	end

	properties (Access = protected)
		output
	end

	methods
		function obj = NIDAQController()
			obj.session = daq.createSession('ni');
		end
        
        function idx = addDigitalOutput(obj, channel)
        	[~, idx] = obj.session.addDigitalChannel('Dev1', channel, 'OutputOnly');
        end
        
        function report(obj)
        	disp(obj.session)
        end

        function digitalWrite(obj, line, val)
        	obj.output(line) = val;
        	obj.session.outputSingleScan(obj.output);
        end
        
    end 
end