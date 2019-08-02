classdef DataPlots < handle
    %-------------------------------------------------------------------------%
    % Superclass that other DataPlot classes derive from. Mainly contains some
    % helper functions for checking input arguments and setting the plotting 
    % data and changing plot props.
    %
    % Current derived classes:
    % RawDataPlots          For cell x n data, "raw data"
    % SummaryDataPlots      For 1 x cell data, from metrics and other summary stuff
    %
    % Written 01Aug2019 KS
    % Updated 02Aug2019 KS  Removed the actual plots from this code to clean it up
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
        
    end
    
    methods (Access = protected)
      
        function args = initializeArgs(obj,num_datasets,varargin) % Wrapper for initialization steps prior to plotting
            if mod(length(varargin),2)
                error('Name-value pairs must be submitted in pairs')
            end
            obj.numDataChecker(num_datasets);
            args = obj.vararginToStruct(varargin{:});
            obj.plotHandles = DataObject(); % Recreate the object. This is because the reset method of DataObject won't kill the entire array
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
        
        function args = vararginToStruct(obj,varargin) % Quick function to turn the varargin cell array into a structure
            nm_pair = reshape(varargin,2,[])'; % reshaping to 2 colums, each row is a Name-Value pair
            args = struct();
            for ii = 1:size(nm_pair,1)
                args.(nm_pair{ii,1}) = nm_pair{ii,2}; % Organizing NM-pairs into structure
            end
        end
        
        function createPlotHandles(obj,varargin)
            
            for ii = 1:length(varargin)
                temp = struct();
                temp.(inputname(ii+1)) = varargin{ii};
                obj.plotHandles(ii) = DataObject();
                obj.plotHandles(ii).importStruct(temp);
            end
    
        end
    end
end