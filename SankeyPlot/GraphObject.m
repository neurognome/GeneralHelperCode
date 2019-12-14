classdef GraphObject < handle
    properties
        input
        output
        amount
        
        color
    end
    
    methods
        function obj = GraphObject(input, output, amount)
            obj.input = input;
            obj.output = output;
            obj.amount = amount;
        end
        
        function setColor(obj, color)
            obj.color = color;
        end
        
        function input = getInput(obj)
            input = obj.input;
        end
        
        function output = getOutput(obj)
            output = obj.output;
        end
        
        function amount = getAmount(obj)
            amount = obj.amount;
        end
    end
    
end