classdef Violin < handle
    % Violin creates violin plots for some data
    %   A violin plot is an easy to read substitute for a box plot
    %   that replaces the box shape with a kernel density estimate of
    %   the data, and optionally overlays the data points itself.
    %
    %   Additional constructor parameters include the width of the
    %   plot, the bandwidth of the kernel density estimation, and the
    %   X-axis position of the violin plot.
    %
    %   Use <a href="matlab:help('violinplot')">violinplot</a> for a
    %   <a href="matlab:help('boxplot')">boxplot</a>-like wrapper for
    %   interactive plotting.
    %
    %   See for more information on Violin Plots:
    %   J. L. Hintze and R. D. Nelson, "Violin plots: a box
    %   plot-density trace synergism," The American Statistician, vol.
    %   52, no. 2, pp. 181-184, 1998.
    %
    % Violin Properties:
    %    ViolinColor - Fill color of the violin area and data points.
    %                  Defaults to the next default color cycle.
    %    ViolinAlpha - Transparency of the ciolin area and data points.
    %                  Defaults to 0.3.
    %    EdgeColor   - Color of the violin area outline.
    %                  Defaults to [0.5 0.5 0.5]
    %    BoxColor    - Color of the box, whiskers, and the outlines of
    %                  the median point and the notch indicators.
    %                  Defaults to [0.5 0.5 0.5]
    %    MedianColor - Fill color of the median and notch indicators.
    %                  Defaults to [1 1 1]
    %    ShowData    - Whether to show data points.
    %                  Defaults to true
    %    ShowNotches - Whether to show notch indicators.
    %                  Defaults to false
    %    ShowMean    - Whether to show mean indicator.
    %                  Defaults to false
    %
    % Violin Children:
    %    ScatterPlot - <a href="matlab:help('scatter')">scatter</a> plot of the data points
    %    ViolinPlot  - <a href="matlab:help('fill')">fill</a> plot of the kernel density estimate
    %    BoxPlot     - <a href="matlab:help('fill')">fill</a> plot of the box between the quartiles
    %    WhiskerPlot - line <a href="matlab:help('plot')">plot</a> between the whisker ends
    %    MedianPlot  - <a href="matlab:help('scatter')">scatter</a> plot of the median (one point)
    %    NotchPlots  - <a href="matlab:help('scatter')">scatter</a> plots for the notch indicators
    %    MeanPlot    - line <a href="matlab:help('plot')">plot</a> at mean value
    
    % Copyright (c) 2016, Bastian Bechtold
    % This code is released under the terms of the BSD 3-clause license
    
    properties
        ScatterPlot % scatter plot of the data points
        ViolinPlot  % fill plot of the kernel density estimate
        BoxPlot     % fill plot of the box between the quartiles
        WhiskerPlot % line plot between the whisker ends
        MedianPlot  % scatter plot of the median (one point)
        NotchPlots  % scatter plots for the notch indicators
        MeanPlot    % line plot of the mean (horizontal line)
    end
    
    properties (Dependent=true)
        ViolinColor % fill color of the violin area and data points
        ViolinAlpha % transparency of the violin area and data points
        EdgeColor   % color of the violin area outline
        BoxColor    % color of box, whiskers, and median/notch edges
        BoxWidth    % width of box between the quartiles in axis space (default 10% of Violin plot width, 0.03)
        MedianColor % fill color of median and notches
        ShowData    % whether to show data points
        ShowNotches % whether to show notch indicators
        ShowMean    % whether to show mean indicator
        LineWidth   % violin outline width
        Max         % maximum y value
        Min         % minimum y value
        ShowBox     % whether to show box plot 
        ShowViolin  % whether to show violin
    end
    
    methods
        function obj = Violin(data, pos, varargin)
            %Violin plots a violin plot of some data at pos
            %   VIOLIN(DATA, POS) plots a violin at x-position POS for
            %   a vector of DATA points.
            %
            %   VIOLIN(..., 'PARAM1', val1, 'PARAM2', val2, ...)
            %   specifies optional name/value pairs:
            %     'Width'        Width of the violin in axis space.
            %                    Defaults to 0.3
            %     'Bandwidth'    Bandwidth of the kernel density
            %                    estimate. Should be between 10% and
            %                    40% of the data range.
            %     'ViolinColor'  Fill color of the violin area and
            %                    data points. Defaults to the next
            %                    default color cycle.
            %     'ViolinAlpha'  Transparency of the violin area and
            %                    data points. Defaults to 0.3.
            %     'EdgeColor'    Color of the violin area outline.
            %                    Defaults to [0.5 0.5 0.5]
            %     'BoxColor'     Color of the box, whiskers, and the
            %                    outlines of the median point and the
            %                    notch indicators. Defaults to
            %                    [0.5 0.5 0.5]
            %     'MedianColor'  Fill color of the median and notch
            %                    indicators. Defaults to [1 1 1]
            %     'ShowData'     Whether to show data points.
            %                    Defaults to true
            %     'ShowNotches'  Whether to show notch indicators.
            %                    Defaults to false
            %     'ShowMean'     Whether to show mean indicator.
            %                    Defaults to false
            
            args = obj.checkInputs(data, pos, varargin{:});
            ind = pos;
            if not(isempty(args.PosSpec))
                pos = args.PosSpec(ind);
            end
            data = data(not(isnan(data)));
            if numel(data) == 1
                obj.MedianPlot = scatter(pos, data, 'filled');
                obj.MedianColor = args.MedianColor;
                obj.MedianPlot.MarkerEdgeColor = args.EdgeColor;
                obj.MedianPlot.SizeData = 20;
                return
            end
            
            hold('on');
            
            % calculate kernel density estimation for the violin
            [density, value] = ksdensity(data, 'bandwidth', args.Bandwidth);
            if not(isempty(args.Max)) && args.Max < max(value)
                args.Max = args.Max;
            else
                args.Max = max(value);
            end
            if not(isempty(args.Min)) && args.Min > min(value)
                args.Min = args.Min;
            else
                args.Min = min(value);
            end
            
            %UNCOMMENT BELOW TO CLIP VIOLINS
            density = density(value >= args.Min & value <= args.Max);
            value = value(value >= args.Min & value <= args.Max);
            value(1) = args.Min;
            value(end) = args.Max;
            
            % all data is identical
            if min(data) == max(data)
                density = 1;
                value = max(data);
            end
            
            width = args.Width/max(density);
            
            % plot the data points within the violin area
            if length(density) > 1
                jitterstrength = interp1(value, density*width, data);
            else % all data is identical:
                jitterstrength = density*width;
            end
            jitter = 2*(rand(size(data))-0.5);
            obj.ScatterPlot = ...
                scatter(pos + jitter.*jitterstrength, data, 'filled');
            
            assignin('base','test',[value value(end:-1:1)])
            % plot the violin
            obj.ViolinPlot =  ... % plot color will be overwritten later
                fill([pos+density*width pos-density(end:-1:1)*width], ...
                [value value(end:-1:1)], [1 1 1]);
            obj.ViolinPlot.LineWidth = args.LineWidth;
            
            % plot the mini-boxplot within the violin
            quartiles = quantile(data, [0.25, 0.5, 0.75]);
            %             obj.BoxPlot = ... % plot color will be overwritten later
            %                 fill(pos+[-1,1,1,-1]*args.BoxWidth, ...
            %                      [quartiles(1) quartiles(1) quartiles(3) quartiles(3)], ...
            %                      [1 1 1]);
            obj.BoxPlot = rectangle('Position',[pos-args.BoxWidth quartiles(1)...
                2*args.BoxWidth quartiles(3)-quartiles(1)],...
                'Curvature',[.4 .1]);
            
            % plot the data mean
            meanValue = mean(data);
            if length(density) > 1
                meanDensityWidth = interp1(value, density, meanValue)*width;
            else % all data is identical:
                meanDensityWidth = density*width;
            end
            if meanDensityWidth<args.BoxWidth/2
                meanDensityWidth=args.BoxWidth/2;
            end
            obj.MeanPlot = plot(pos+[-1,1].*meanDensityWidth, ...
                [meanValue, meanValue]);
            obj.MeanPlot.LineWidth = 1;
            
            IQR = quartiles(3) - quartiles(1);
            lowhisker = quartiles(1) - 1.5*IQR;
            lowhisker = max(lowhisker, min(data(data > lowhisker)));
            hiwhisker = quartiles(3) + 1.5*IQR;
            hiwhisker = min(hiwhisker, max(data(data < hiwhisker)));
            if ~isempty(lowhisker) && ~isempty(hiwhisker)
                obj.WhiskerPlot = plot([pos pos], [lowhisker hiwhisker]);
                obj.WhiskerPlot.LineWidth = args.LineWidth;
            end
            obj.MedianPlot = scatter(pos, quartiles(2), [], [1 1 1], 'filled');
            obj.MedianPlot.SizeData = 20;
            
            obj.NotchPlots = ...
                scatter(pos, quartiles(2)-1.57*IQR/sqrt(length(data)), ...
                [], [1 1 1], 'filled', '^');
            obj.NotchPlots(2) = ...
                scatter(pos, quartiles(2)+1.57*IQR/sqrt(length(data)), ...
                [], [1 1 1], 'filled', 'v');
            
            obj.EdgeColor = args.EdgeColor;
            obj.BoxColor = args.BoxColor;
            obj.BoxWidth = args.BoxWidth;
            obj.MedianColor = args.MedianColor;
            if not(isempty(args.ViolinColor))
                obj.ViolinColor = args.ViolinColor(ind,:);
            else
                obj.ViolinColor = obj.ScatterPlot.CData;
            end
            obj.ViolinAlpha = args.ViolinAlpha;
            obj.ShowData = args.ShowData;
            obj.ShowNotches = args.ShowNotches;
            obj.ShowMean = args.ShowMean;
            obj.ShowBox = args.ShowBox;
            obj.ShowViolin = args.ShowViolin;
        end
        
        function set.EdgeColor(obj, color)
            if ~isempty(obj.ViolinPlot)
                obj.ViolinPlot.EdgeColor = color;
            end
        end
        
        function color = get.EdgeColor(obj)
            if ~isempty(obj.ViolinPlot)
                color = obj.ViolinPlot.EdgeColor;
            end
        end
        
        function set.MedianColor(obj, color)
            obj.MedianPlot.MarkerFaceColor = color;
            if ~isempty(obj.NotchPlots)
                obj.NotchPlots(1).MarkerFaceColor = color;
                obj.NotchPlots(2).MarkerFaceColor = color;
            end
        end
        
        function color = get.MedianColor(obj)
            color = obj.MedianPlot.MarkerFaceColor;
        end
        
        function set.BoxColor(obj, color)
            if ~isempty(obj.BoxPlot)
                obj.BoxPlot.FaceColor = color;
                obj.BoxPlot.EdgeColor = color;
                obj.WhiskerPlot.Color = color;
                obj.MedianPlot.MarkerEdgeColor = color;
                obj.NotchPlots(1).MarkerFaceColor = color;
                obj.NotchPlots(2).MarkerFaceColor = color;
            end
        end
        
        function color = get.BoxColor(obj)
            if ~isempty(obj.BoxPlot)
                color = obj.BoxPlot.FaceColor;
            end
        end
        
        function set.BoxWidth(obj,width)
            if ~isempty(obj.BoxPlot)
                pos = obj.BoxPlot.Position(1)+obj.BoxPlot.Position(3)/2;
                obj.BoxPlot.Position(1) = pos-width;
                obj.BoxPlot.Position(3) = 2*width;
                %                 pos=mean(obj.BoxPlot.XData);
                %                 obj.BoxPlot.XData=pos+[-1,1,1,-1]*width;
            end
        end
        
        function width = get.BoxWidth(obj)
            width = obj.BoxPlot.Position(3);
            %             width=max(obj.BoxPlot.XData)-min(obj.BoxPlot.XData);
        end
        
        function set.ViolinColor(obj, color)
            obj.ViolinPlot.FaceColor = color;
            obj.ScatterPlot.MarkerFaceColor = color;
            obj.MeanPlot.Color = color;
        end
        
        function color = get.ViolinColor(obj)
            color = obj.ViolinPlot.FaceColor;
        end
        
        function set.ViolinAlpha(obj, alpha)
%             obj.ScatterPlot.MarkerFaceAlpha = alpha;
            obj.ViolinPlot.FaceAlpha = alpha;
        end
        
        function alpha = get.ViolinAlpha(obj)
            alpha = obj.ViolinPlot.FaceAlpha;
        end
        
        function set.ShowData(obj, yesno)
            if yesno
                obj.ScatterPlot.Visible = 'on';
            else
                obj.ScatterPlot.Visible = 'off';
            end
        end
        
        function yesno = get.ShowData(obj)
            if ~isempty(obj.ScatterPlot)
                yesno = strcmp(obj.ScatterPlot.Visible, 'on');
            end
        end
        
        function set.ShowNotches(obj, yesno)
            if ~isempty(obj.NotchPlots)
                if yesno
                    obj.NotchPlots(1).Visible = 'on';
                    obj.NotchPlots(2).Visible = 'on';
                else
                    obj.NotchPlots(1).Visible = 'off';
                    obj.NotchPlots(2).Visible = 'off';
                end
            end
        end
        
        function yesno = get.ShowNotches(obj)
            if ~isempty(obj.NotchPlots)
                yesno = strcmp(obj.NotchPlots(1).Visible, 'on');
            end
        end
        
        function set.ShowMean(obj, yesno)
            if ~isempty(obj.MeanPlot)
                if yesno
                    obj.MeanPlot.Visible = 'on';
                else
                    obj.MeanPlot.Visible = 'off';
                end
            end
        end
        
        function yesno = get.ShowMean(obj)
            if ~isempty(obj.MeanPlot)
                yesno = strcmp(obj.MeanPlot.Visible, 'on');
            end
        end
        
        function set.ShowViolin(obj, yesno)
            if ~isempty(obj.MeanPlot)
                if yesno
                    obj.ViolinPlot.Visible = 'on';
                else
                    pos = obj.BoxPlot.Position(1);
                    obj.ViolinPlot.Visible = 'off';
                    %obj.BoxPlot.Position(1) = pos-.2;
                    %obj.MedianPlot.XData = pos-.2+obj.BoxPlot.Position(3)/2;
                    %obj.WhiskerPlot.XData = [pos-.2+obj.BoxPlot.Position(3)/2 ...
                    %    pos-.2+obj.BoxPlot.Position(3)/2];
                    jitter = obj.ScatterPlot.XData - round(obj.ScatterPlot.XData);
                    jitter = (jitter - min(jitter))/2;
                    obj.ScatterPlot.XData = jitter+pos+.1+obj.BoxPlot.Position(3);
                end
            end
        end
        
        function yesno = get.ShowViolin(obj)
            if ~isempty(obj.ViolinPlot)
                yesno = strcmp(obj.ViolinPlot.Visible, 'on');
            end
        end
        
        function set.LineWidth(obj, linewidth)
            if ~isempty(obj.ViolinPlot)
                obj.ViolinPlot.LineWidth = linewidth;
            end
        end
        
        function linewidth = get.LineWidth(obj)
            if ~isempty(obj.ViolinPlot)
                linewidth = obj.ViolinPlot.LineWidth;
            end
        end
        
        function set.Max(obj, Max)
            if ~isempty(obj.ViolinPlot)
                
            end
        end
        
        function Max = get.Max(obj)
            if ~isempty(obj.ViolinPlot)
                Max = max(obj.ViolinPlot.YData);
            end
        end
        
        function set.Min(obj, Min)
            if ~isempty(obj.ViolinPlot)
                
            end
        end
        
        function Min = get.Min(obj)
            if ~isempty(obj.ViolinPlot)
                Min = min(obj.ViolinPlot.YData);
            end
        end
        
        function set.ShowBox(obj, yesno)
            if ~isempty(obj.BoxPlot)
                if yesno
                    obj.BoxPlot.Visible = 'on';
                    obj.MedianPlot.Visible = 'on';
                    obj.WhiskerPlot.Visible = 'on';
                else
                    obj.BoxPlot.Visible = 'off';
                    obj.MedianPlot.Visible = 'off';
                    obj.WhiskerPlot.Visible = 'off';
                end
            end
        end
        
        function yesno = get.ShowBox(obj)
            if ~isempty(obj.BoxPlot)
                yesno = strcmp(obj.BoxPlot.Visible, 'on');
            end
        end

    end
    
    methods (Access=private)
        function results = checkInputs(obj, data, pos, varargin)
            isscalarnumber = @(x) (isnumeric(x) & isscalar(x));
            p = inputParser();
            p.addRequired('Data', @isnumeric);
            p.addRequired('Pos', isscalarnumber);
            p.addParameter('Width', 0.4, isscalarnumber);
            p.addParameter('Bandwidth', [], isscalarnumber);
            iscolor = @(x) (isnumeric(x) & length(x) == 3);
            p.addParameter('ViolinColor', [], @isnumeric);
            p.addParameter('BoxColor', [.2 .2 .2], iscolor);
            p.addParameter('BoxWidth', 0.04, isscalarnumber);
            p.addParameter('EdgeColor', [.2 .2 .2], iscolor);
            p.addParameter('LineWidth', 1.5, isscalarnumber);
            p.addParameter('MedianColor', [1 1 1], iscolor);
            p.addParameter('ViolinAlpha', 0.3, isscalarnumber);
            isscalarlogical = @(x) (islogical(x) & isscalar(x));
            p.addParameter('ShowData', true, isscalarlogical);
            p.addParameter('ShowNotches', false, isscalarlogical);
            p.addParameter('ShowMean', false, isscalarlogical);
            p.addParameter('Max',[], isscalarnumber);
            p.addParameter('Min',[], isscalarnumber);
            p.addParameter('ShowBox', true, isscalarlogical);
            p.addParameter('ShowViolin', true, isscalarlogical);
            p.addParameter('PosSpec', [], @isnumeric);
            
            p.parse(data, pos, varargin{:});
            results = p.Results;
        end
    end
end
