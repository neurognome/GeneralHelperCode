classdef DataPlots < handle
    properties
        data
        plotHandles
    end
    
    methods
        function obj = DataPlots() % empty contsructor, because nothing happens by default...
            % initialize dataobjects
            obj.data = DataObject();
            obj.plotHandles = DataObject();
        end
        
        function obj = setPlottingData(obj,varargin) % varargin because sometimes you need 2 datasets (eg scatter plots)
            obj.data.reset(); % Get rid of old data from previous plot
            temp = struct(); % Temporarly assign to a structure so it goes into the DataObject easier
            for ii = 1:length(varargin)
                d = varargin{ii};
                if isvector(d) && (size(d,2) > size(d,1)) % If it's a row vector, transpose into a column vector
                    d = d';
                end
                temp.(sprintf('data%d',ii)) = d; % Assign in increasing number, so we know...
            end
            obj.data.importStruct(temp); % Absorb the structure
        end
        
        function obj = setPlotProps(obj,varargin) % Used to pass name-value pairs into the plot
            [h,args] = obj.checkPlotProps(varargin{:});
            
            % Setting the properties
            plotHandleProps = properties(obj.plotHandles(h)); % Convert plot properties and input angs to same format
            argFields       = fields(args);
            for a = 1:length(argFields) % Go through all the supplied ags
                obj.plotHandles(h).(plotHandleProps{1}).(argFields{a}) = args.(argFields{a}); % heavy use of dynamic names..
            end
        end
        %----------------------------------Plots----------------------------------%
        function polarPlot(obj,varargin) % As an example, there's there parts to this
            % Initializing and preparing for plotting
            [c,args] = obj.initialize(1,varargin{:});
            
            % Calculation of data necessary from the raw data
            rho = obj.data.data1(c,:);
            rho = [rho rho(1)];           
            theta = linspace(0,2*pi, size(obj.data.data1,2)+1);
            
            % The actual plotting
            clf
            ax = polaraxes();
            line = polarplot(theta,rho);
            obj.plotHandles(1) = DataObject('line');
            obj.plotHandles(2) = DataObject('ax');
            
            % Setting the plot styles
            % Default look
            obj.setPlotProps(1,'LineWidth',2);
            obj.setPlotProps(2,'ThetaZeroLocation','top','ThetaDir','clockwise');
            
            % User-defined look
            obj.setPlotProps(args);
        end
        
        function linePlot(obj,varargin)
            [c,args] = obj.initialize(1,varargin{:});
            
            line = plot(obj.data.data1(c,:));
            
            obj.plotHandles(1) = DataObject('line');    
            obj.setPlotProps(1,'LineWidth',2);
            obj.setPlotProps(args);
            
        end
        
        
        
    end
    
    methods (Access = private)
        function [h,args] = checkPlotProps(obj,varargin) % Used to make sure the inputs to setPlotProps are in the correct format
            if ~isnumeric(varargin{1}) % Checking if h_num is supplied, and adjusting based on that
                h = 1;
            else
                h = varargin{1};
                varargin = varargin(2:end); % Correct the varargin if the first one is good
            end
            
            if isstruct(varargin{1}) % Checking for an "argument" structure, as opposed to individual name value pairs
                args = varargin{1};
            else
                args = obj.vararginToStruct(varargin{:}); % If they're name-value pairs, then convert into argument structure
            end
        end
        
        
        function [c,args] = initialize(obj,num_datasets,varargin) % Wrapper for initialization steps prior to plotting
            obj.numDataChecker(num_datasets);
            [c,args] = obj.argChecker(varargin{:});
            delete(obj.plotHandles);
        end
        
        function numDataChecker(obj,expected) % Checking for the number of datasets supplied, and wheter or not that's compatible with the plot being made
            supplied = length(properties(obj.data)) ;
            if supplied ~= expected
                error('Expected %d set(s) of data, received %d. Reload your data.',expected,supplied)
            end
        end
        
        function [c,args] = argChecker(obj,varargin) % Argument checker for the plot.
            if nargin < 2
                c = randi(size(obj.data.data1,1));
                fprintf('No cell chosen, randomly selected cell #%d\n',c);
            else
            if isvector(obj.data.data1) % If the data are in a vector, c = 1; since that's your only option...
                c = 1;
            else
                if ~isscalar(varargin{1}) % If a matrix, need to specify the cell number you want to plot
                    c = randi(size(obj.data.data1,1));
                    fprintf('No cell chosen, randomly selected cell #%d\n',c);
                else
                    c = varargin{1};
                    varargin = varargin(2:end); % Get rid of the cell number for the remainder...
                end
            end
            end
            % Construct arguments
            if mod(length(varargin),2)
                error('Name-value pairs must be submitted in pairs')
            end
            
            args = obj.vararginToStruct(varargin{:});
        end
        
        function args = vararginToStruct(obj,varargin) % Quick function to turn the varargin cell array into a structure
            nm_pair = reshape(varargin,2,[])'; % reshaping to 2 colums, each row is a Name-Value pair
            args = struct();
            for ii = 1:size(nm_pair,1)
                args.(nm_pair{ii,1}) = nm_pair{ii,2}; % Organizing NM-pairs into structure
            end
        end
    end
end