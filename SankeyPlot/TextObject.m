classdef TextObject < handle
    
    properties
        parent_obj % The graph object that the text object is a child of 
        
        % Font information etc
    end
    
    methods
        function obj = TextObject(parent_obj)
            obj.parent_obj = parent_obj; % Needs a parent to get info from
        end
        
        function draw(obj)
            % Create this text on the graph
            text(obj.parent_obj.getVertex(2), obj.parent_obj.getCenter(), obj.parent_obj.getName(), ....
                'HorizontalAlignment', 'left', 'FontWeight', 'bold');
        end
    end
end