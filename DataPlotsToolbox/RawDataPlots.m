classdef RawDataPlots < DataPlots
    %------------------------------------------------------------------------------------------------------------
    % For visualization of "raw data". Essentially any data that abides by the 
    % format of cells x n, where n can be frames, bins, etc.
    %
    % Currently supported plots:
    % Name                  Descrip.                                            Num Datasets    Data format(s)
    % polarPlot             Standard polar plots for circular data              1               cells x n, numeric array
    % linePlot              Standard line plot... for... everything             1               cells x n, numeric array
    % heatmapPlot           Heat map of your matrix. Can take two forms of      1               cells x n x r, numeric array (choose a cell)
    %                       inputs                                                              cells x n, numeric array
    %
    % Written 01Aug2019 KS
    % Updated 02Aug2019 KS  Refactored from DataPlots
    % -----------------------------------------------------------------------------------------------------------
    properties
    end
    
    methods
        function obj = RawDataPlots() % empty contsructor, because nothing happens by default...

        end
        
        function polarPlot(obj,varargin) % As an example, there's there parts to this
            % Initializing and preparing for plotting
            [c,varargin] = obj.getCell(varargin{:});
            args = obj.initializeArgs(1,varargin{:});
            % Calculation of data necessary from the raw data
            rho = obj.data.data1(c,:);
            rho = [rho rho(1)];
            
            if isfield(args,'Rectify')
                if args.Rectify
                    rho(rho<0) = 0;
                    %rho = rho - min(rho(:));
                end
                args = rmfield(args,'Rectify');
            end    

            theta = linspace(0,2*pi, size(obj.data.data1,2)+1);
            
            % Plot the data
            line = polarplot(theta,rho,'-o');
            ax = gca;
            
            % Get the handles for changing values
            obj.createPlotHandles(line,ax);    

            
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
        
        function heatmapPlot(obj,varargin)
            data = obj.data.get('data1');
            
            if ndims(data) == 3
               [c,varargin] = obj.getCell(varargin{:});
               data = permute(data,[2 3 1]); % putting cells last to save squeezes
            else 
                c = 1; % No cells provided, so you heatmap the whole thing
            end
            
            args = obj.initializeArgs(1,varargin{:});
            
            h = imagesc(data);
            ax = get(gca);
            
        obj.createPlotHandles(h,ax);    
        
        end
    end
    
    methods (Access = protected)
        function [c,varargin] = getCell(obj,varargin) % Argument checker for the plot.
            if nargin < 2
                c = randi(size(obj.data.data1,1));
                fprintf('No cell chosen, randomly selected cell #%d\n',c);
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
        end
    end
end