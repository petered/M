function h=addline(strips, orient, varargin)

% Simple Way to add vertical or horizontal lines to a plot. 
% Examples: 
% h=addline([1 1.4 2],'h','color','r');  Would add 3 horizontal red lines
%                                        to your plot at x=[1 1.4 2].
% addline([1 1.4 2]);                    Would add 3 vertical grey lines at
%                                        these points.
% addline([3 4.2], 'vh')                 Would add crosshairs at x=3,y=4.2
% 
% 'strips' specifies the coordinates of the strips, 
% 'color', specifies the colour of each line.  If there are 3 columns, it 
% will be interpretied as RGB.  color can also be a predefined color.  The
% rows of the 'colour' vector represent the color for each line.  The 
% colour for each line is determined by rotating around the colour vectors.
% 'LineStyle' will be interpreted as it is in the Matlab 'line' function.


%% Get Arguments

strips=reshape(strips,1,[]);

% To keep compatibility with older versions
if ~exist('orient','var')
    orient='v';
elseif exist('orient','var') && ~all(orient=='v'|orient=='h')
    varargin=[orient varargin];
    orient='v';
end
% 
% for i=1:2:(length(varargin)-1)
%    if strcmpi('Color', varargin{i})
%        colour=varargin{i+1};
%    elseif strcmpi('LineStyle', varargin{i})
%        pattern=varargin{i+1}; 
%    elseif strcmpi('LineWidth', varargin{i})
%        width=varargin{i+1}; 
%    % compatibility...
%    elseif strcmpi('orientation', varargin{i})
%        
%        switch varargin{i+1}
%            case 0, orient='v';
%            case 1, orient='h';
%        end
% %    /compatibility
%    else
%        disp('This function takes "satfire", "threshold", and "show" as arguments.  None of this ', varargin{i}, ' nonsense');
%    end
% end
   
%% Set Defaults

% Default Color
if ~exist('colour', 'var')
    colour=[.5 .5 .5];
elseif strcmp(colour, 'auto')
    colour=(lines(size(strips,2)));    
end

% Default Orientation: vertical
if ~exist('orient', 'var')
    orient='v'; %meaning vertical
end

% Get full orientation vector
if numel(orient)==1
    orient=repmat(orient,[1 length(strips)]);
elseif numel(orient)~=numel(strips)
    disp('Warning: Wrong number of line orientations provided for line vector.  Lines will not be plotted');
    h=-1;
    return;
end

% Line patten default
if ~exist('pattern', 'var')
    pattern='-';
end

% Line width default
if ~exist('width', 'var')
    width=1;
end

%% Actual program

% Get previous axis settings
v=axis;
a=ishold;
xlim=get(gca,'XLim');
ylim=get(gca,'YLim');

hold on
axis manual

% h=NaN([1 length(strips)]);
% for i=1:length(strips)
%     col=colour(mod(i-1,size(colour,1))+1,:);
%     if orient(i)=='h'
%     h(i)=line([v(1) v(2)],[strips(i) strips(i)],  'color', col, 'LineStyle', pattern,'LineWidth',width);  
%     elseif orient(i)=='v'
%     h(i)=line([strips(i) strips(i)], [v(3) v(4)], 'color', col, 'LineStyle', pattern,'LineWidth',width);
%     end
% end

[xtags ytags]=deal(nan(2,length(strips)));



if any(orient=='v')
    xtags(:,orient=='v')=repmat(strips(orient=='v'),[2,1]);
    ytags(:,orient=='v')=repmat(v([3 4])',[1 nnz(orient=='v')]);
end
if any(orient=='h')
    xtags(:,orient=='h')=repmat(v([1 2])',[1 nnz(orient=='h')]);    
    ytags(:,orient=='h')=repmat(strips(orient=='h'),[2,1]);
end

h=plot(xtags,ytags, 'color', colour,varargin{:});



if ~a, hold off; end

set(gca,'Xlim',xlim);
set(gca,'Ylim',ylim);


end