classdef DataPlots < handle
    %-------------------------------------------------------------------------%
    % A big class that handles all the visualization and plotting of various
    % data types. Create the object, then set your data. Call from any of the
    % predefined plots, and pass Name-Value pairs via setPlotProps.
    %
    % Currently supported plots:
    % Name                  Descrip.                                            Num Datasets    Data formats
    % polarPlot             Standard polar plots for circular data              1               m x n arrays
    % linePlot              Standard line plot... for... everything             1               m x n arrays
    % confidenceBandPlot    Scatter plot with overlaid regression line with a   2               1 x n arrays
    %                       error band around it (Needs the confidenceBandPlot
    %                       class)
    % boxPlot               Box plot for comparing medians                      1               1 x n cell array
    %
    % Written 01Aug2019 KS
    % Updated
    % ------------------------------------------------------------------------%
    
    %% To add your own plots, copy this skeleton code
    % % Initializing and preparing for plotting
    %   [c, varargin] = obj.getCell(varargin{:}); % This line is only necessary if you give single cell data
    %   [args] = obj.initializeArgs(#,varargin{:}); %  # = number of input arguments to your main plot
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
    %    obj.setProps(1,'LineWidth',2); % Set defaults
    % % User-defined look
    %    obj.setProps(args); % Pass in name-value pairs
    %%
    properties
       % data
    end

    properties (Access = protected)
        plotHandles
    end
    
    methods
        function obj = DataPlots() % empty contsructor, because nothing happens by default...
            % initialize dataobjects
          %  obj.data = DataObject();
            obj.plotHandles = DataObject();
        end
        
        function obj = setData(obj,varargin) % varargin because sometimes you need 2 datasets (eg scatter plots)
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
        
        function obj = setProps(obj,varargin) % Used to pass name-value pairs into the plot
            [h,args] = obj.checkPlotProps(varargin{:});
            
            % Setting the properties
            plotHandleProps = properties(obj.plotHandles(h)); % Convert plot properties and input angs to same format
            argFields       = fields(args);
            for a = 1:length(argFields) % Go through all the supplied ags
                obj.plotHandles(h).(plotHandleProps{1}).(argFields{a}) = args.(argFields{a}); % heavy use of dynamic names..
            end
        end
        
%         %----------------------Plots--------------------------%
%         function polarPlot(obj,varargin) % As an example, there's there parts to this
%             % Initializing and preparing for plotting
%             [c,varargin] = obj.getCell(varargin{:});
%             args = obj.initializeArgs(1,varargin{:});
%             
%             % Calculation of data necessary from the raw data
%             rho = obj.data.data1(c,:);
%             rho = [rho rho(1)];
%             theta = linspace(0,2*pi, size(obj.data.data1,2)+1);
%             
%             % Plot the data
%             clf
%             ax = polaraxes();
%             line = polarplot(theta,rho);
%             
%             % Get the handles for changing values
%             obj.plotHandles(1) = DataObject('line');
%             obj.plotHandles(2) = DataObject('ax');
%             
%             % Setting the plot styles
%             % Default look
%             obj.setProps(1,'LineWidth',2);
%             obj.setProps(2,'ThetaZeroLocation','top','ThetaDir','clockwise');
%             
%             % User-defined look
%             obj.setProps(args);
%         end
%         
%         function linePlot(obj,varargin)
%             [c,varargin] = obj.getCell(varargin{:});
%             args = obj.initializeArgs(1,varargin{:});
%             
%             line = plot(obj.data.data1(c,:));
%             ax   = gca;
%             obj.plotHandles(1) = DataObject('line');
%             obj.plotHandles(2) = DataObject('ax');
%             
%             obj.setProps(1,'LineWidth',2);
%             obj.setProps(args);
%         end
        
        function confidenceBandPlot(obj,varargin)
            % Initializing and preparing for plotting
            args = obj.initializeArgs(2,varargin{:});
            
            % Calculation of data necessary from the raw data
            
            % Plot the data
            cb_plot = confidenceBandPlot(obj.data.data1,obj.data.data2);
            ax      = get(gca);
            % Get the handles for changing values
            obj.plotHandles(1) = DataObject('cb_plot');
            obj.plotHandles(2) = DataObject('ax');
            
            % Setting the plot styles
            obj.setProps(args); % Pass in name-value pairs
        end
        
        function boxPlot(obj,varargin)
            % Initializing and preparing for plotting
            args = obj.initializeArgs(1,varargin{:});
            
            if ~isempty(fields(args))
                fprintf('Warning, boxplots are annoying, can''t set properties...\n')
                args = varargin; % workaround
            end
            
            % Calculation of data necessary from the raw data
            if size(obj.data.data1{1},1) < size(obj.data.data1{1},2)
                d = cellfun(@transpose,obj.data.data1,'UniformOutput',false);
            else
                d = obj.data.data1;
            end
            
            group_sz = cellfun(@length,d);
            
            groups = [];
            for ii = 1:length(group_sz)
                groups = cat(2,groups,ii*ones(1,group_sz(ii)));
            end
            d = cat(1,d{:});
            
            % Plot the data
            boxplot(d,groups,args{:});
            ax = get(gca);
            % Get the handles for changing values
            h = findobj(gca);
            obj.plotHandles(1) = DataObject(h);
            obj.plotHandles(2) = DataObject(ax);
    
            % Boxplots are hard to deal with because they're like 30 different
            % plots on top of one another... don't currently have functionality to 
            % change individual parts...
        end
    end
    
    methods (Access = protected)
      
        function args = initializeArgs(obj,num_datasets,varargin) % Wrapper for initialization steps prior to plotting
            obj.numDataChecker(num_datasets);
            args = obj.vararginToStruct(varargin{:});
            obj.plotHandles.reset;
        end
        
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
        
        function numDataChecker(obj,expected) % Checking for the number of datasets supplied, and wheter or not that's compatible with the plot being made
            supplied = length(properties(obj.data)) ;
            if supplied ~= expected
                error('Expected %d set(s) of data, received %d. Reload your data.',expected,supplied)
            end
        end
        
        function [c,varargin] = getCell(obj,varargin) % Argument checker for the plot.
            if nargin < 2
                c = randi(size(obj.data.data1,1));
            else
                if isvector(obj.data.data1)
                    c = 1;
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