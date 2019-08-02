classdef RawDataPlots < DataPlots
   properties
        data
    end

    properties (Access = protected)
      %  plotHandles
    end
    methods
        function obj = RawDataPlots() % empty contsructor, because nothing happens by default...
            % initialize dataobjects
            obj.data = DataObject();
            obj.plotHandles = DataObject();
        end
        
        %----------------------Plots--------------------------%
        function polarPlot(obj,varargin) % As an example, there's there parts to this
            % Initializing and preparing for plotting
            [c,varargin] = obj.getCell(varargin{:});
            args = obj.initializeArgs(1,varargin{:});
            
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
            obj.setProps(1,'LineWidth',2);
            obj.setProps(2,'ThetaZeroLocation','top','ThetaDir','clockwise');
            
            % User-defined look
            obj.setProps(args);
        end
        
        function linePlot(obj,varargin)
            [c,varargin] = obj.getCell(varargin{:});
            args = obj.initializeArgs(1,varargin{:});
            
            line = plot(obj.data.data1(c,:));
            ax   = gca;
            obj.plotHandles(1) = DataObject('line');
            obj.plotHandles(2) = DataObject('ax');
            
            obj.setProps(1,'LineWidth',2);
            obj.setProps(args);
        end
    end
end