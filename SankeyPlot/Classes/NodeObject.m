classdef NodeObject < GraphObject
    properties
        name
        level
        center
        vertices
        width = 0.1; % Default width
    end
    
    methods
        function obj = NodeObject(name, amount, level, input, output)
            obj@GraphObject(input, output, amount)
            obj.name = name;
            obj.level = level;
        end
        
        function generateVertices(obj)
            x_left = obj.level - obj.width;
            x_right = obj.level + obj.width;
            
            y_bot = obj.center - obj.amount/2;
            y_top = obj.center + obj.amount/2;
            
            obj.vertices = [x_left x_right y_bot y_top];
        end
        
        function width = getWidth(obj)
            width = obj.width;
        end
        
        function setWidth(obj, width)
            obj.width = width;
        end
        
        function level = getLevel(obj)
            level = obj.level;
        end
        
        function center = getCenter(obj)
            center = obj.center;
        end
        
        function name = getName(obj)
            name = obj.name;
        end
        
        function vertices = getVertex(obj, vertex_id)
            if nargin < 2 || isempty(vertex_id)
                vertices = obj.vertices;
            else
                vertices = obj.vertices(vertex_id);
            end
        end
        
        function setCenter(obj, center)
            obj.center = center;
        end
        
        function setVertices(obj, vertices)
            obj.vertices = vertices;
        end
        
        function draw(obj)            
            % Create the node
            patch([obj.vertices(1), obj.vertices(2), obj.vertices(2), obj.vertices(1)],...
                [obj.vertices(3), obj.vertices(3), obj.vertices(4), obj.vertices(4)], obj.color,...
                'LineStyle', 'none');
        end
    end
end