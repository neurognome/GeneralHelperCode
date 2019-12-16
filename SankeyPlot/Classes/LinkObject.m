classdef LinkObject < GraphObject
    properties
        input_vertices
        output_vertices
        
        alpha = 0.5;
    end
    
    methods
        function obj = LinkObject(input, output, amount)
            obj@GraphObject(input, output, amount)
        end
        
        function setOutputVertices(obj, vertices)
            obj.output_vertices = vertices;
        end
        
        function setInputVertices(obj, vertices)
            obj.input_vertices = vertices;
        end
        
        function vertex = getVertex(obj, vertex_idx, side)
            switch side
                case 'input'
                    vertex = obj.input_vertices(vertex_idx);
                case 'output'
                    vertex = obj.output_vertices(vertex_idx);
            end
        end
        
        function setAlpha(obj, alpha)
            obj.alpha = alpha;
        end
        
        function draw(obj)   
            % Draw this link
         
            sigmoid_sharpness = 5; % > 5 or else you lose the asymptotes
            modelfun = @(x, a, offset, shift)  a * ((tanh(sigmoid_sharpness * (x - 1.5 - (shift - 1))) + 1) * 0.5) + offset; %10 defines sharpness
            
            x = linspace(mean(obj.output_vertices([1, 2])), mean(obj.input_vertices([1, 2]))); % Create a smooth x vector
                        
            % Calculate the top sigmoid
            amp = obj.input_vertices(4) - obj.output_vertices(4);
            offset = obj.output_vertices(4);
            shift = x(1);
            y1 = modelfun(x, amp, offset, shift);
            
            % Calculate the bottom sigmoid
            amp = obj.input_vertices(3) - obj.output_vertices(3);
            offset = obj.output_vertices(3);
            y2 = modelfun(x, amp, offset, shift);
       
            patch([x, fliplr(x)], [y1, fliplr(y2)], obj.color, 'LineStyle', 'none', 'FaceAlpha', obj.alpha)
        end
    end
end
