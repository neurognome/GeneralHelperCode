classdef confidenceBandPlot < handle
    %--------------------------------------------------------------------------
    % Lets you plot confidence band plots over a scatter plot
    %
    % Usage: confidenceBandPlot(IV,DV,'Name',value);
    %
    % Possible name-value pairs     Default values          Description
    % ScatterColor              = [0.7 0.7 0.7]         Color of the dots for the scatter plot
    % RegressionLineColor       = [1 1 1]               Color of the regression line
    % ConfidenceBandColor       = [1 0 0]               Color of the confidence band
    % RegressionLineThickness   = 2                     Line thickness of the regression line
    % ConfidenceInterval        = 0.95                  What CI to show in the band
    % ConfidenceBandAlpha       = 0.5                   Band transparency
    % NumBootstrapSamples       = 1000                  Number of samples for bootstrapping the error
    %
    %
    % Additional Info: The confidence band bounds are calculated by bootstrapping
    % the population NumBootstrapSamples times and then taking the 95th and 5th
    % percentile of that distribution at each data point to create a smooth curve
    %
    % Written 24Jul2019 KS
    % Updated
    %--------------------------------------------------------------------------
    
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
        ConfidenceBandAlpha         % Transparency of the confidence band
        
    end
    
    properties (SetAccess = protected)
        NumBootstrapSamples         % Number of samples for the bootstrap
        ConfidenceInterval          % What CI to represent [0,1];
    end
    
    methods
        function obj = confidenceBandPlot(IV,DV,varargin)
            % Make sure both are column vectors
            
            IV = obj.columnVectorMaker(IV);
            DV = obj.columnVectorMaker(DV);
            
            % Parse the input arguments, in case you supply some, and apply as necessary. The rest are defaulted
            args = obj.checkInputs(IV,DV,varargin{:});
            hold on
            
            % Calculate both the confidence band and sampled X and Y values for the regression line
            [X,Y,Y_top,Y_bot] = obj.calculateConfidenceBand(IV,DV,args.ConfidenceInterval,args.NumBootstrapSamples);
            
            % Plotting everything
            % scatterplot, with filled circles
            obj.ScatterPlot = ...
                scatter(IV,DV,'filled');
            
            % confidence bounds, no edges. requires a color argument
            obj.ConfidenceBand = ...
                fill([X , fliplr(X)],[Y_bot , fliplr(Y_top)], args.ConfidenceBandColor,'EdgeColor','none');
            
            % plot subsampled regression line
            obj.RegressionLine = ...
                plot(X,Y);
            
            % Set all the colors and linestyles to make it look pretty
            obj.ScatterColor            = args.ScatterColor;
            obj.RegressionLineColor     = args.RegressionLineColor;
            obj.ConfidenceBandColor     = args.ConfidenceBandColor;
            obj.ConfidenceBandAlpha     = args.ConfidenceBandAlpha;
            obj.RegressionLineThickness = args.RegressionLineThickness;
            
            % Just for your own reference
            obj.NumBootstrapSamples     = args.NumBootstrapSamples;
            obj.ConfidenceInterval      = args.ConfidenceInterval;
            
            hold off % for future plotting
        end
        
        % Bunch of getters and setters... These allow me to access these dependent values outside of the function, ie it lets me change it from the command window if I want
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
            p.addParameter('NumBootstrapSamples',500,isscalarnumber);
            
            p.parse(IV,DV,varargin{:});
            results = p.Results;
        end
        
        function [X,Y,Y_top,Y_bot] = calculateConfidenceBand(obj,x,y,ci,numIterations)
            x_min = min(x);
            x_max = max(x);
            n_pts = 100;
            
            X = x_min:(x_max-x_min)/n_pts:x_max; % subsampling the population
            beta = polyfit(x,y,1);
            Y = ones(size(X))*beta(2) + beta(1)*X; % Calculating y values based on fit...
            
            % Bootstrapping the confidence band
            for s = 1:numIterations
                [x_sample,idx] = datasample(x,length(x)-1);
                y_sample = y(idx);
                beta_samp = polyfit(x_sample,y_sample,1);
                Y_samp(s,:) = ones(size(X))*beta_samp(2) + beta_samp(1)*X; % Calculating y values based on fit...
            end
            
            % Taking the 5% and 95% as the top and bottom of the confidence band
            Y_top = prctile(Y_samp,ci*100);
            Y_bot = prctile(Y_samp,(1-ci)*100);
        end
        
        function vec = columnVectorMaker(obj,vec)
            [nrow,ncol] = size(vec);
            if nrow > ncol
                vec = vec';
            end
        end
    end
    
end

