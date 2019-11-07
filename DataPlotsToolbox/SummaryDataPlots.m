classdef SummaryDataPlots < DataPlots
%-------------------------------------------------------------------------------------------------------------------------
% Handles plotting of summany data. Generally you take your data and 
% get some kind of metric with it. Then you can use this to see that metric
% and help to visualize statistical significance. If you want to plot cells, see RawDataPlots.
%
% Currently supported plots:
% Name                  Descrip.                                            Num Datasets    Data format(s)
% confidenceBandPlot    Scatter plot with overlaid regression line with a   2               1 x cells, numeric array
%                       error band around it (Needs the confidenceBandPlot
%                       class)
% boxPlot               Box plot for comparing medians                      1               1 x groups, cell array
% histogramPlot         Simple histogram with mean line                     1               1 x cells, numeric array
% 
% Written 01Aug2019 KS
% Updated 02Aug2019 KS  Refactored from DataPlots
% ------------------------------------------------------------------------------------------------------------------------
    
    properties
    end
    
    methods
        function obj = SummaryDataPlots()
            
        end
        
        
        function confidenceBandPlot(obj,varargin)
            % Initializing and preparing for plotting
            args = obj.initializeArgs(2,varargin{:});
            
            % Calculation of data necessary from the raw data
            
            % Plot the data
            h = confidenceBandPlot(obj.data.data1,obj.data.data2);
            ax      = get(gca);
            % Get the handles for changing values
            obj.createPlotHandles(h,ax);

            
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
                d = cellfun(@transpose,obj.data.get('data1'),'UniformOutput',false);
            else
                d = obj.data.get('data1');
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
            obj.createPlotHandles(h,ax);

            
            % Boxplots are hard to deal with because they're like 30 different
            % plots on top of one another... don't currently have functionality to
            % change individual parts...
        end
        
        function histogramPlot(obj,varargin)
            args = obj.initializeArgs(1,varargin{:});
            
            h = histogram(obj.data.get('data1'));
            hold on
            l = line([mean(obj.data.data1) mean(obj.data.data1)],...
                ylim, 'LineWidth',2,'Color','r');
            hold off
            
            ax = get(gca);
            obj.createPlotHandles(h,ax,l);
            
            obj.setProps(args);
        end
    end
end
