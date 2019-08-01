classdef DataPlots < handle
%-------------------------------------------------------------------------%
% A big class that handles all the visualization and plotting of various 
% data types. Create the object, then set your data. Call from any of the
% predefined plots, and pass Name-Value pairs via setPlotProps.
% 
% Currently supported plots:
% 
% polarPlot             Standard polar plots for circular data
% linePlot              Standard line plot... for... everything
% confidenceBandPlot    Scatter plot with overlaid regression line with a 
%                       error band around it (Needs the confidenceBandPlot
%                       class)
%
% Written 01Aug2019 KS
% Updated 
% ------------------------------------------------------------------------%

%% Skeleton code 
% % To add your own plots, copy this skeleton code
% % Initializing and preparing for plotting
%   [c,args] = obj.initialize(#,varargin{:}); %  # = number of input arguments to your main plot
%             
% % Calculation of data necessary from the raw data
%     obj.data.data# % retrieve data from the DataObject
%     
% % Plot the data
%    h = whateverplotyouneed(obj.data.data#)
% 
% % Get the handles for changing values
%    obj.plotHandles(1) = DataObject('h');
%             
% % Setting the plot styles
%    obj.setPlotProps(1,'LineWidth',2); % Set defaults    
% % User-defined look
%    obj.setPlotProps(args); % Pass in name-value pairs
%%
properties (Access = protected)
        data
        plotHandles
    end
    
    methods
        function obj = DataPlots() % empty contsructor, because nothing happens by default...
            % initialize dataobjects
            obj.data = DataObject();
            obj.plotHandles = DataObject();
        end
        
        function obj = setPlotData(obj,varargin) % varargin because sometimes you need 2 datasets (eg scatter plots)
            obj.data.reset(); % Get rid of old data from previous plot
            temp = struct(); % Temporarly assign to a structure so it goes into the DataObject easier
            for ii = 1:length(varargin)
                d = varargin{ii};
                if isvector(d) && (size(d,2) < size(d,1)) % If it's a row vector, transpose into a column vector
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
        
        %----------------------Plots--------------------------%
        function polarPlot(obj,varargin) % As an example, there's there parts to this
            % Initializing and preparing for plotting
            [c,args] = obj.initialize(1,varargin{:});
            
            % Calculation of data necessary from the raw data
            rho = obj.data.data1(c,:);
            rho = [rho rho(1)];
            theta = linspace(0,2*pi, size(obj.data.data1,2)+1);
            
            % Plot the data
            clf
            ax = polaraxes();
            line = polarplot(theta,rho);
            
            % Get the handles for changing values
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
        
        function confidenceBandPlot(obj,varargin)
            % Initializing and preparing for plotting
            [c,args] = obj.initialize(2,varargin{:}); 
            
            % Calculation of data necessary from the raw data

            % Plot the data
            cb_plot = confidenceBandPlot(obj.data.data1,obj.data.data2);
            
            % Get the handles for changing values
            obj.plotHandles(1) = DataObject('cb_plot');
            
            % Setting the plot styles
            obj.setPlotProps(args); % Pass in name-value pairs
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
            else
                if isvector(obj.data.data1)
                    c = 1;
                    fprintf('Vector data, cell set to #1\n');
                    if isnumeric(varargin{1}) % If a cell number was supplied anyway, get rid of it
                        varargin = varargin(2:end); % Get rid of the cell number for the remainder...
                    end
                else
                    if isnumeric(varargin{1})
                        c = varargin{1};
                        fprintf('Plotting cell %d\n',c);
                        varargin = varargin(2:end); % Get rid of the cell number for the remainder...
                    else
                        c = randi(size(obj.data.data1,1));
                        fprintf('No cell chosen, randomly selected cell #%d\n',c);
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