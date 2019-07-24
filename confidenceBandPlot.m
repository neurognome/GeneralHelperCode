classdef confidenceBandPlot < handle
    %-------------------------------------------------------------------------%
    % Lets you plot confidence band plots over a scatter plot
    % Usage: confidenceBandPlot(IV,DV,'Name',value);
    %
    % Possible name-value pairs     Default values          Description
    % ScatterColor              = [0.7 0.7 0.7]         Color of the dots for the scatter plot
    % RegressionLineColor       = [1 1 1]               Color of the regression line 
    % ConfidenceBandColor       = [1 0 0]               Color of the confidence band
    % RegressionLineThickness   = 2                     Line thickness of the regression line
    % ConfidenceInterval        = 0.95                  What CI to show in the band
    % ConfidenceBandAlpha       = 0.5                   Band transparency
    %
    % Written 24Jul2019 KS
    % Updated
    %-------------------------------------------------------------------------%
    
    properties (Access = private)
        ScatterPlot                 % scatter plot of the raw data
        RegressionLine              % regression line on top
        ConfidenceBand              % Shaded polygon of the confindence bounds
    end
    
    properties (Dependent = true)
        ScatterColor                % Color of the dots for the scatter plot
        RegressionLineColor         % Color of the regression line
        ConfidenceBandColor         % Color of the confidence band
        RegressionLineThickness     % Thickness of the Regression line
        ConfidenceInterval          % What CI to represent [0,1];
        ConfidenceBandAlpha         % Transparency of the confidence band
    end
    
    methods
        function obj = confidenceBandPlot(IV,DV,varargin)
            % Make sure both are column vectors
            if size(IV,2) ~= 1
                IV = IV';
            end
            
            if size(DV,2) ~= 1
                DV = DV';
            end
            
            % Parse the input arguments, in case you supply some, and apply as necessary. The rest are defaulted
            args = obj.checkInputs(IV,DV,varargin{:});
            hold on
            
            % Calculate both the confidence band and sampled X and Y values for the regression line
            [X,Y,Y_top,Y_bot] = obj.calculateConfidenceBand(IV,DV,args.ConfidenceInterval);
            
            % Plotting everything
            % scatterplot, with filled circles
            obj.ScatterPlot = ...
                scatter(IV,DV,'filled');
            
            % confidence bounds, no edges. requires a color argument
            obj.ConfidenceBand = ...
                fill([X , fliplr(X)],[Y_bot , fliplr(Y_top)],args.ConfidenceBandColor,'EdgeColor','none');
            
            % plot subsampled regression line
            obj.RegressionLine = ...
                plot(X,Y);
            
            % Set all the colors and stuff so we can see it.
            obj.ScatterColor            = args.ScatterColor;
            obj.RegressionLineColor     = args.RegressionLineColor;
            obj.ConfidenceBandColor     = args.ConfidenceBandColor;
            obj.ConfidenceBandAlpha     = args.ConfidenceBandAlpha;
            obj.RegressionLineThickness = args.RegressionLineThickness;
            
            hold off % for future plotting
            
        end
        
        % Bunch of getters and setters... These allow me to access these values outside of the function, ie it lets me change it from the command window if I want
        
        function set.ScatterColor(obj,color)
            if ~isempty(obj.ScatterPlot)
                obj.ScatterPlot.MarkerFaceColor = color;
            end
        end
        
        function color = get.ScatterColor(obj)
            if ~isempty(obj.ScatterPlot)
                color = obj.ScatterPlot.MarkerFaceColor;
            end
        end
        
        function set.RegressionLineColor(obj,color)
            if ~isempty(obj.RegressionLine)
                obj.RegressionLine.Color = color;
            end
        end
        
        function color = get.RegressionLineColor(obj)
            if ~isempty(obj.RegressionLine)
                color = obj.RegressionLine.Color;
            end
        end
        
        function color = get.ConfidenceBandColor(obj)
            if ~isempty(obj.ConfidenceBand)
                color = obj.ConfidenceBand.FaceColor;
            end
        end
        
        function set.ConfidenceBandColor(obj,color)
            if ~isempty(obj.ConfidenceBand)
                obj.ConfidenceBand.FaceColor = color;
            end
        end
        
        function alpha = get.ConfidenceBandAlpha(obj)
            if ~isempty(obj.ConfidenceBand)
                alpha = obj.ConfidenceBand.FaceAlpha;
            end
        end
        
        function set.ConfidenceBandAlpha(obj,alpha)
            if ~isempty(obj.ConfidenceBand)
                obj.ConfidenceBand.FaceAlpha = alpha;
                obj.ConfidenceBand.EdgeAlpha = alpha;
            end
        end
        
        function linewidth = get.RegressionLineThickness(obj)
            if ~isempty(obj.RegressionLine)
                linewidth = obj.RegressionLine.LineWidth;
            end
        end
        
        function set.RegressionLineThickness(obj,linewidth)
            if ~isempty(obj.RegressionLine)
                obj.RegressionLine.LineWidth = linewidth;
            end
        end
        
        function ci = get.ConfidenceInterval(obj)
            ci = obj.ConfidenceInterval;
        end
        
        function set.ConfidenceInterval(obj,ci)
            obj.ConfidenceInterval = ci;
        end
        
        
    end
    
    methods (Access = private)
        % This function lets me check the inputs I give and assign correctly
        function results = checkInputs(obj,IV,DV,varargin)
            isscalarnumber = @(x) (isnumeric(x) & isscalar(x));
            p = inputParser();
            p.addRequired('IV',@isnumeric);
            p.addRequired('DV',@isnumeric);
            p.addParameter('RegressionLineThickness',2,isscalarnumber);
            iscolor = @(x) (isnumeric(x) & length(x) == 3);
            p.addParameter('ScatterColor',[0.7,0.7,0.7],iscolor);
            p.addParameter('RegressionLineColor',[0 0 0],iscolor);
            p.addParameter('ConfidenceBandColor',[1 0.7 0.7],iscolor);
            p.addParameter('ConfidenceBandAlpha',0.5,isscalarnumber);
            p.addParameter('ConfidenceInterval',0.95,isscalarnumber);
            
            p.parse(IV,DV,varargin{:});
            results = p.Results;
        end
        
        % This calculates the confidence band, I think somethign's wrong here...
        function [X,Y,Y_top,Y_bot] = calculateConfidenceBand(obj,x,y,ci)
            N = length(x);
            x_min = min(x);
            x_max = max(x);
            
            n_pts = 100;
            
            % calculate the necessary parameters...
            beta = fliplr(polyfit(x,y,1));
            
            
            X = x_min:(x_max-x_min)/n_pts:x_max; % subsampling the population
            Y = ones(size(X))*beta(1) + beta(2)*X; % Calculating y values based on fit...
            
            SE_y_cond_x = sqrt(sum((y - (beta(1)*ones(size(y)) + beta(2)*x)).^2)./N);
            SSX = (N-1)*var(x);
            SE_Y = SE_y_cond_x*(ones(size(X))*(1/N + (mean(x)^2)/SSX) + (X.^2 - 2*mean(x)*X)/SSX);
            
            Yoff = (2*finv(1-ci,2,N-2)*SE_Y).^0.5;
            
            
            % SE_b0 = SE_y_cond_x*sum(x.^2)/(N*SSX)
            % sqrt(SE_b0)
            
            Y_top = Y + Yoff;
            Y_bot = Y - Yoff;
            
        end
    end
end

