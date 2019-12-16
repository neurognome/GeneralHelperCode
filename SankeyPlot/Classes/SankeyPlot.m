classdef SankeyPlot < handle
    % Creates nice(ish) looking Sankey Plots for seeing how your cells (or other data) splits in the hierarchy. Data must be
    % inputted as follows:
    
    % {'input', 'output', amount}, where 'input' is the left node, 'output' is the right node and amount is the #
    % Store this as a matrix of cell arrays, at N x 3, where N is the number of relationships you have.
    
    % Currently no error checking... so be careful
    
    % Written 14Dec2019 KS
    % Updated
    
    properties
        spacing = 0.05; % 5% of max node size
        nodes
        links
        labels
    end
    
    methods
        function obj = SankeyPlot(data)
            obj.parseInputs(data)
            figure
            set(gca, 'XColor', 'none')
        end
        
        function parseInputs(obj, input)
            % The purpose of this function is to take the input and do some preprocessing into useful formats and instantiate
            % all of our objects for later use
            
            if size(input, 2) ~= 3
                error('Your data are in the wrong format, needs to be a cell array: {source, target, amt} for each link')
            end
            
            %% Numberize nodes so you know parent-child relationships
            node_names = unique(input(:, 1:2), 'stable');
            n_nodes = length(node_names);
            
            numberized_nodes = zeros(size(input));
            
            node_id = 1;
            for i_node = 1:length(node_names)
                is_current_node = cellfun(@(x) strcmp(x, node_names(i_node)), input);
                numberized_nodes(is_current_node) = node_id;
                node_id = node_id + 1;
            end
            
            numberized_nodes(:, 3) = cat(1, input{:, 3});
            
            
            
            %% Determine the node hierarchy through some beautiful spaghetti
            node_hierarchy = zeros(1, n_nodes);
            
            % Find all nodes w/o inputs, classify them as level 1
            for i_node = 1:n_nodes
                if sum(numberized_nodes(:, 2) == i_node) == 0
                    node_hierarchy(i_node) = 1;
                end
            end
            
            % Go through a couple times and find nodes that build on previous level, moving up the chain
            for rep = 1:10
                for ii = 1:n_nodes
                    prev_nodes = numberized_nodes(numberized_nodes(:, 2) == ii, 1);
                    prev_levels = unique(node_hierarchy(prev_nodes)); % all hierarchies of previous nodes
                    if ~isempty(prev_levels)
                        node_hierarchy(ii) = max(prev_levels) + 1; % Eventually, we'll find al evel 2 node...
                    end
                end
            end
            
            % Find all nodes without outputs and classify them as level max
            for i_node = 1:n_nodes
                if sum(numberized_nodes(:, 1) == i_node) == 0
                    node_hierarchy(i_node) = max(node_hierarchy);
                end
            end
               
          
            %% Determine the amounts for each node            
            % Clean this up... especially the "else" portion
            amounts = zeros(1, n_nodes);
            for i_node = 1:n_nodes
                if node_hierarchy(i_node) == 1
                    is_current_node = logical(sum(numberized_nodes(:, 1) == i_node, 2));
                    amounts(i_node) =  sum([input{is_current_node, 3}]);
                elseif node_hierarchy(i_node) == max(node_hierarchy)
                    is_current_node = logical(sum(numberized_nodes(:, 2) == i_node, 2));
                    amounts(i_node) =  sum([input{is_current_node, 3}]);
                else
                    is_current_node = logical(sum(numberized_nodes(:, 1) == i_node, 2));
                    temp(1) =  sum([input{is_current_node, 3}]);
                    is_current_node = logical(sum(numberized_nodes(:, 2) == i_node, 2));
                    temp(2) =   sum([input{is_current_node, 3}]);
                    
                    amounts(i_node) = max(temp);
                end
            end
            
            obj.spacing = max(amounts) .* obj.spacing;
            
            %% Instantiate all objects
            for i_node = 1:n_nodes
                input = numberized_nodes(numberized_nodes(:, 2) == i_node, 1); % Get the previous node of the current node
                output = numberized_nodes(numberized_nodes(:, 1) == i_node, 2);
                if i_node == 1
                    obj.nodes =  NodeObject(node_names(i_node), amounts(i_node), node_hierarchy(i_node), input, output);
                    obj.labels = TextObject(obj.nodes(i_node));
                else
                    obj.nodes(i_node) = NodeObject(node_names(i_node), amounts(i_node), node_hierarchy(i_node), input, output);
                    obj.labels(i_node) = TextObject(obj.nodes(i_node));
                end
            end
            
            for i_link = 1:size(numberized_nodes, 1)
                if i_link == 1
                    obj.links = LinkObject(...
                        numberized_nodes(i_link, 1), numberized_nodes(i_link, 2), numberized_nodes(i_link, 3));
                else
                    obj.links(i_link) = LinkObject(...
                        numberized_nodes(i_link, 1), numberized_nodes(i_link, 2), numberized_nodes(i_link, 3));
                end
            end
        end
        
        function preprocessData(obj)
            % The purpose of this function is to do all the necessary calculations (especially for nodes) to get spacings and
            % locations set for the nodes
            
            levels = obj.getAllLevels(); % Return all the possible levels (hierarchies)
            
            for i_level = 1:max(levels) % Since this is hierarchical, each hierarchical level is dealt with one at a time
                nodes_in_hierarchy = find(levels == i_level); % First find the nodes that belong to this current hierarchical level
                n_nodes_to_plot = length(nodes_in_hierarchy);
                
                % Get previous nodes for proper sorting
                previous_node_centers = zeros(1, n_nodes_to_plot); % Find the previous nodes for each of the curretn nodes
                node_values = zeros(1, n_nodes_to_plot);
                
                % These steps need to be run on the entire hierarchy at once (group agnostic)
                previous_ceil = 0;
                ct = 1;
                for node = nodes_in_hierarchy
                   previous_node = obj.nodes(node).getInput(); % This is not the best way to do this, because "input" is a property of the link, not the node... but this will work for new
                   if length(previous_node) == 1 % only one previous
                        previous_node_centers(ct) = obj.nodes(previous_node).getCenter;
                    else % Multiple previous nodes
                        temp = zeros(1, length(previous_node));
                        for ii = 1:length(previous_node)
                            temp(ii) = obj.nodes(previous_node(ii)).getCenter;
                        end
                        previous_node_centers(ct) = mean(temp);
                    end
                    
                    node_values(ct) = obj.nodes(node).getAmount(); % Value of the current nodes in level, in a vector
                    
                    obj.nodes(node).setCenter(previous_ceil + node_values(ct) / 2); % Setting center based on previous node
                    
                    previous_ceil = sum(node_values(1:ct)); % Running total to make sure it's in the right place
                    ct = ct + 1;
                end
               
                % These steps are group by group dependent, so are run afterwards, moving the centers away from each
                % other      
                
                % Use all the information to finally set the vertices
                for node = nodes_in_hierarchy
                    obj.nodes(node).generateVertices();
                end
                
                %Final step to adjust the spacing, run 10X to ensure no collisions lol
                if numel(nodes_in_hierarchy) > 1 
                   obj.spaceNodes(nodes_in_hierarchy);
                end
                obj.alignNodeGroups(nodes_in_hierarchy);
            end
            
            % Here we see if any nodes are directly aligned with other nodes and shift them if so...
            % This isn't perfect, but I don't have the foresight to generate data to break this... so I'll use it until it
            % stops working right, then i'll come back and fix this
            for i_node = 1:length(obj.nodes)
                center = obj.nodes(i_node).getCenter();
                if i_node ~= 1 % First node no shift
                    if center == obj.nodes(i_node - 1).getCenter()
                        span = obj.nodes(i_node-1).getVertex(4) - obj.nodes(i_node-1).getVertex(3);
                        obj.nodes(i_node - 1).setCenter(center - span/2);
                        obj.nodes(i_node).setCenter(center + span/2); % randomly shift
                        obj.nodes(i_node).generateVertices();
                        obj.nodes(i_node - 1).generateVertices();
                    end
                end
                
            end
            
            % Setting colors for our objects
            obj.setNodeColors(); % Not ideal, but we need to set the colors here because the links are dependent on the nodes
            obj.setLinkColors();
            
            obj.calculateConnectionPoints();
        end
        
        % Creating each portion of the graph
        function createLabels(obj)
            for label = obj.labels
                label.draw();
            end
        end
        
        function createLinks(obj)
            for link = obj.links
                %obj.drawSimpleLink(i_link)
                link.draw();
            end
        end
        
        function createNodes(obj)
            for node = obj.nodes
                node.draw();
            end
        end
        
        % these are for updating and changing the graph... doesn't work right now (need a separate version that sets then
        % replots
        
        function changeLinkColor(obj, color)
            obj.setLinkColors(color)
            obj.replot();
        end
        
        function changeNodeColor(obj, color, update_links)
            if nargin < 3 || isempty(update_links)
                update_links = false;
            end
            obj.setNodeColors(color)
            obj.replot();
            
            if update_links
                obj.setLinkColors();
                obj.replot();
            end
        end
    end
    
    
    methods (Access = protected)
        function calculateConnectionPoints(obj)
            % The purpose of this function is to calculate input (left) and output (right) connection points for each node
            for i_node = 1:length(obj.nodes)
                % This also sorts the links. Finds all the links connected to the node on either side
                input_links = obj.findLinks(i_node, 'input');
                output_links = obj.findLinks(i_node, 'output');
                
                obj.setLinkVertices(input_links, i_node, 'input')
                obj.setLinkVertices(output_links, i_node, 'output')
            end
        end
        
        function setLinkColors(obj, color)
            % actually changing the link colors
            for link = obj.links
                if ~exist('color', 'var') %Nothing provided
                    link.setColor(obj.generateColor(link)); % can't be done in the link object, because requires node information
                else
                    link.setColor(color)
                end
            end
        end
        
        function setNodeColors(obj, color)
            % Actually changing the node colors
            if nargin < 2 || isempty(color)
                color = lines(length(obj.nodes)); % Default
            end
            
            if size(color, 1) < length(obj.nodes) % Single color provided
                fprintf('You gave %d colors, but there are %d nodes, repeating last color\n', ...
                    size(color, 1), length(obj.nodes))
                for ii = 1:(length(obj.nodes) - size(color, 1))
                    color = [color; color(end, :)];
                end
            end
            for i_node = 1:length(obj.nodes)
                obj.nodes(i_node).setColor(color(i_node, :))
            end
        end
        
        function replot(obj)
            cla;
            obj.createLinks();
            obj.createNodes();
            obj.createLabels();
        end
        
        function alignNodeGroups(obj, nodes)
            % This function aligns all the nodes in the hierarchy to the "midline" of the graph, so the graph doesn't just
            % keep shifting in one direction
            persistent graph_mid_point
            current_level = obj.nodes(nodes(1)).getLevel();
            ct = 1;
            lo_temp = zeros(1, length(nodes));
            hi_temp = zeros(1, length(nodes));
            for node = nodes
                lo_temp(ct) = obj.nodes(node).getVertex(3);
                hi_temp(ct) = obj.nodes(node).getVertex(4);
                ct = ct + 1;
            end
            lo = min(lo_temp);
            hi = max(hi_temp);
            mid_point = (lo + hi) / 2 + lo;
            
            if current_level == 1
                graph_mid_point = mid_point;
            else
                shift = mid_point - graph_mid_point;
                for node = nodes
                    obj.nodes(node).setCenter(obj.nodes(node).getCenter() - shift);
                    obj.nodes(node).generateVertices();
                end
            end
        end
        
        function spaceNodes(obj, nodes)
            ct = 1;
            for i_node = 1:length(nodes)
               % centers(i_node) = obj.nodes(nodes(i_node)).getCenter();
                obj.nodes(nodes(i_node)).setCenter(obj.nodes(nodes(i_node)).getCenter() + (ct * obj.spacing));
                obj.nodes(nodes(i_node)).generateVertices();
                ct = ct + 1;
            end
            
        end
        
        function spaceNodesoldold(obj, nodes)
            pool = zeros(length(nodes), 4);
            ct = 1;
            for node = nodes
                pool(ct, :) = obj.nodes(node).getVertex(); % Get all the nodes in the current pool
                ct = ct+1;
            end
            
            for i_node = 1:length(nodes) % Detect collision and shift
                current_bounds = pool(i_node, [3, 4]);
                other_bounds = pool(1:end ~= i_node, [3, 4]);
                shift = 0;
                
                for ii = 1:size(other_bounds, 1)
                    %Check collision
                    if current_bounds(1) >= other_bounds(ii, 1) && current_bounds(1) <= other_bounds(ii, 2)
                        % Lower bound is touching
                        shift = other_bounds(ii, 2) - current_bounds(1);
                        obj.nodes(nodes(i_node)).setCenter(obj.nodes(nodes(i_node)).getCenter() + shift + obj.spacing);
                        
                    elseif current_bounds(2) >= other_bounds(ii, 1) && current_bounds(2) <= other_bounds(ii, 2)
                        % Upper bound is touching
                        shift = current_bounds(2) - other_bounds(ii, 1);
                        obj.nodes(nodes(i_node)).setCenter(obj.nodes(nodes(i_node)).getCenter() + shift + obj.spacing);
                        
                    end
                end
                
                obj.nodes(nodes(i_node)).generateVertices();
            end
        end
        
        function spaceNodesOLD(obj, nodes)
            % To space the nodes to meet the predefined spacing
            % To do: change the spacing method so it's not just pushed in one direction every time
            pool = zeros(length(nodes), 4);
            ct = 1;
            for node = nodes
                pool(ct, :) = obj.nodes(node).getVertex(); % Get all the nodes in the current pool
                ct = ct+1;
            end
            
            ct = 0;
            for i_node = 1:length(nodes) % Detect collision and shift
                lo = pool(i_node, 3);
                
                i_collision = (pool(1:end ~= i_node, [3, 4]) - lo) < 0.01; % weird issue with rounding, adding some tolerance
                
                for ii = 1:size(i_collision, 1)
                    if any(i_collision(ii, :))
                        pool(i_node, [3, 4]) = pool(i_node, [3, 4]) + (pool(ii, 4) - pool(i_node, 3)) + obj.spacing; % If collision, move it
                        ct = ct + 1;
                    end
                end
                
            end
            
            ct = 1;
            for node = nodes % Reset the vertices and center after adjustments
                obj.nodes(node).setVertices(pool(ct, :));
                obj.nodes(node).setCenter(sum(pool(ct, [3, 4]))/2)
                ct = ct+1;
            end
        end
        
        function out = generateColor(obj, link)
            % Getting colors for the links from previous nodes
            out = obj.nodes(link.getInput()).color;
        end
        
        function levels = getAllLevels(obj)
            % Returns all hierarchical levels, since each node object holds its own level
            levels = zeros(1, length(obj.nodes));
            for ii = 1:length(obj.nodes)
                levels(ii) = obj.nodes(ii).getLevel;
            end
        end
        
        function out = findLinks(obj, node, side)
            % Find links to the current node, side dependent
            is_link = false(1, length(obj.links));
            for i_link = 1:length(obj.links)
                switch side % Flipped b/c inputs of the link mean output
                    case 'output'
                        is_link(i_link) = node == obj.links(i_link).getInput();
                    case 'input'
                        is_link(i_link) = node == obj.links(i_link).getOutput();
                end
            end
            
            out = obj.sortLinks(find(is_link), side); % Sort the links
        end
        
        function setLinkVertices(obj, links, node, side)
            % Setting the actual vertices for each link, requires information about node, so it's out here
            running_total = 0;
            for l = links
                link_amt = obj.links(l).getAmount();
                bottom = obj.nodes(node).getVertex(3) + running_total;
                switch side
                    case 'input'
                        obj.links(l).setInputVertices([obj.nodes(node).getVertex(1), obj.nodes(node).getVertex(2),...
                            bottom, bottom + link_amt]);
                    case 'output'
                        obj.links(l).setOutputVertices([obj.nodes(node).getVertex(1), obj.nodes(node).getVertex(2),...
                            bottom, bottom + link_amt]);
                end
                running_total = running_total + link_amt;
            end
        end
        
        function sorted_links = sortLinks(obj, links, side)
            % Sorts links to prevent links from crossing
            order = zeros(size(links));
            ct = 1;
            for l = links
                switch side
                    case 'input'
                        order(ct) = obj.nodes(...
                            obj.links(l).getInput()).getCenter(); % get the center of the node which the link connects to
                    case 'output'
                        order(ct) = obj.nodes(...
                            obj.links(l).getOutput()).getCenter(); % get the center of the node which the link connects to
                end
                ct = ct + 1;
            end
            [~, idx] = sort(order);
            
            sorted_links = links(idx);
        end
    end
    
    methods (Static = true)
        function data = readJSON(fn)
            if nargin < 1 || isempty(fn)
                fn = uigetfile('.json');
            end
            json_struct = jsondecode(fileread(fn));
            node_lookup = {json_struct.nodes.name};
            
            link_array = struct2cell(json_struct.links);
            
            data = cell(size(link_array));
            for i_col = 1:size(data, 2)
                data{1, i_col} = node_lookup{link_array{1, i_col} + 1}; % Because MATLAB is 1 based
                data{2, i_col} = node_lookup{link_array{2, i_col} + 1};
                data{3, i_col} = link_array{3, i_col};
            end
            data = data'; % Transpose
            
        end
        
        function data = readCSV(fn)
            if nargin < 1 || isempty(fn)
                fn = uigetfile('.csv');
            end
            [values, names] =  xlsread(fn);
            names = names(2:end, 1:2); % Take the names, and don't include the table headers
            
            data = cat(2, names, num2cell(values));
        end
    end
end

%% Deprecated code

  %Adjust nodes to align groups to the previous node, not sure if we need this anymore, we'll see...
                % I think here's it's getting info from the wrong groups....
%                  unique_previous_centers = unique(previous_node_centers, 'stable'); % Not all nodes are from the same input, so separate based on input first
%                 for ii = 1:length(unique_previous_centers)
%                     is_grouped = previous_node_centers == unique_previous_centers(ii); % Current input node that are grouped together (touching)
%                     center = zeros(1, length(is_grouped));
%                     ct = 1;
%                     for node = nodes_in_hierarchy(is_grouped)
%                         center(ct) = obj.nodes(node).getCenter(); % Get centers of nodes in group
%                         ct = ct + 1;
%                     end
%                     
%                     [bottom_center, bot_idx] = min(center(is_grouped)); % Following lines are to calculate how much to move the center
%                     [top_center, top_idx] = max(center(is_grouped)); % Get the VALUE and the NODE_ID of the top and bottom nodes
%                     group_center = ((top_center + node_values(top_idx)/2) - (bottom_center - node_values(bot_idx)/2)) / 2+ ...
%                         (bottom_center - node_values(bot_idx)/2); % span of the group / 2 and adjusted for bottom
%                     shift = unique_previous_centers(ii) - group_center; % Shift the center of each group (same input) to the center of the previous node (lining them up)
%                     center(is_grouped) = center(is_grouped) + shift; % Perform the shift
% 
%                     ct = 1;
%                     for node = nodes_in_hierarchy(is_grouped) % After shifting, re-set the center
%                         obj.nodes(node).setCenter(center(ct));
%                         obj.nodes(node).generateVertices();
%                         ct = ct+1;
%                     end
%                 end-


% Move this to LinkObject later
%         function drawSimpleLink(obj, link_id) % If you prefer linear links
%             modelfun = @(x, slope, intercept) slope * x + intercept;
%
%             slope = obj.links(link_id).getVertex(4, 'input') - obj.links(link_id).getVertex(4, 'output');
%             intercept = [obj.links(link_id).getVertex(3, 'output'), obj.links(link_id).getVertex(4, 'output')];
%             x = linspace(obj.nodes(obj.links(link_id).getInput()).getLevel(), obj.nodes(obj.links(link_id).getOutput()).getLevel(), 100); % Get the hierarchical levels of the nodes which these connect to
%
%             y1 = modelfun(x, slope, intercept(1)) - x(1) * slope; % The subtraction is to account for the fact that it's not "relative" but absolute lines, so they get more offset as you move right
%             y2 = modelfun(x, slope, intercept(2)) - x(1) * slope;
%
%             patch([x, fliplr(x)], [y1, fliplr(y2)], [0.5 0.5 0.5], 'LineStyle', 'none', 'FaceAlpha', 0.5)
%
%         end
