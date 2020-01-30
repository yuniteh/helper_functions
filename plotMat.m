function plotMat(mat,varargin)
%PLOTMAT plots the matrix with colorscale, absolute numbers
%   
%
%
%   Arguments
%   mat:            a matrix
%   labels (optional):  vector of class labels

% number of arguments

% default values
matrange = [0 100];
mat(isnan(mat))=0; % in case there are NaN elements
numx = size(mat, 2); % number of labels
numy = size(mat, 1);
xticks = 1:numx;
yticks = 1:numy;
xlab = 'x';
ylab = 'y';
colors = 'blue';

% customizable properties
tmp = strcmpi(varargin,'xticks');
if any(tmp)
    xticks = varargin{find(tmp)+1};
end
    
tmp = strcmpi(varargin,'yticks');
if any(tmp)
    yticks = varargin{find(tmp)+1};
end

tmp = strcmpi(varargin,'colors');
if any(tmp)
    colors = varargin{find(tmp)+1};
end

tmp = strcmpi(varargin,'xlabel');
if any(tmp)
    xlab = varargin{find(tmp)+1};
end

tmp = strcmpi(varargin,'ylabel');
if any(tmp)
    ylab = varargin{find(tmp)+1};
end

tmp = strcmpi(varargin,'range');
if any(tmp)
    matrange = varargin{find(tmp)+1};
end

% plotting the colors
imagesc(mat,matrange);
xlabel(xlab); ylabel(ylab);

% set the colormap
colormap(linspecer(colors));

% Create strings from the matrix values and remove spaces
textStrings = num2str(mat(:), '%.2f');
textStrings = strtrim(cellstr(textStrings));

% Create x and y coordinates for the strings and plot them
[x,y] = meshgrid(1:numx,1:numy);
hStrings = text(x(:),y(:),textStrings(:), ...
    'HorizontalAlignment','center',...
    'FontName','Cambria');

% Get the middle value of the color range
midValue = mean(get(gca,'CLim'));

% Choose white or black for the text color of the strings so
% they can be easily seen over the background color
textColors = repmat(mat(:) > midValue,1,3);
set(hStrings,{'Color'},num2cell(textColors,2));

% Setting the axis labels
set(gca,'XTick',1:numx,...
    'XTickLabel',xticks,...
    'YTick',1:numy,...
    'YTickLabel',yticks,...
    'TickLength',[0 0],...
    'FontName','Cambria');
end