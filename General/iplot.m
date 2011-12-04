function varargout=iplot(varargin)
% iplot
%
% Eg: 
% iplot(y,'r')
% h=iplot(x,y,'plotsetting1','plotvalue1',...)
% etc...
% Exact same syntax as plot.
%
% This function is more or less an improvement on Matlab's plot.  You know
% when you have a huge vector and you plot it, and then you're sitting 
% there staring at the screen like a fool while you wait for it to show? 
% The point of this is to fix that.  It just plots the most extreme points
% in each column of pixels, not the ones that you wouln't see anyway.
%
% Things to improve in the future:
% - You can't just save the plot and load it back up again, it'll be
%   messed.  This may be improvable by storing the full data in the
%   'UserData' property and somehow re-adding the listener when the 
%   figure's opened, or just loading it all into xdata,ydata when saved.
% - Optimize timing - there're some tradeoffs with using the different
%   compressing options that could be optimized
% - Add option for really fast random subsampling, removing all O(N) 
%   operations. (could be good for when you've got very huge vectors)
% - Make it work for y-axis, unsorted x-axes, multiple sets of xdata
% - Also, you may get some funny-looking results if your points aren't
%   connected by lines.
% - Whenever you zoom or pan, the iplot plots brought to the front.  This 
%   may be a good thing or bad thing for you.
%
% Other than that, it seems to work fine.
%
% You're welcome for saving your time.
%
% Peter
% oconnorp .at. ethz _dot_ ch


% How many pixels.
magicnumber=5000;

linfind=@(el,list) round((el-list(1))/(list(end)-list(1))*length(list)+1);

sortfind=@(el,list) round(quickfind(el,list));

%% Setup numeric inputs
yD=varargin{1};
if isvector(yD), yD=yD(:); end

if length(varargin)>1 && isnumeric(varargin{2}) % x-data included
   if ~isvector(yD)
       disp 'iplot doesn''t work for non-vector x-data yet..plotting normally'
       hP=plot(varargin{:});
       if nargout>0, varargout{1}=hP; end
       return;
   end
   if ~issorted(yD) % Ach this is O(N), I know, but for consumer-protection's sake.
       disp 'iplot doesn''t work for unsorted x-data yet...plotting normally'
       hP{:}=plot(varargin{:});
       if nargout>0, varargout{1}=hP; end
       return;
   end
   
   xD=yD;
   yD=varargin{2};
   if isvector(yD), yD=yD(:); end
   
   finder=sortfind;
   
   varargin=varargin(3:end);
else                      % x-data not included
   xD=(1:size(yD,1))';
   finder=linfind;
   varargin=varargin(2:end);
end

if length(xD)<magicnumber
    % Don't bother
    hP=plot(xD,yD,varargin{:});
    if nargout>0, varargout{1}=hP; end
    return;
end


% Cellify the yD
if isvector(yD)
    yD={yD};
else
    yD=num2cell(yD,1); 
end


%% Points-getting function
    function [xP yP]=getPoints(lims,dlims)
        % Return appropriate x,y points given plot handle.  If plot handle
        % doesn't exist yet, give it an empty.
        %
        % Internal variables:
        % lims: current x-limits for the plot's axes
        % range: range of data indeces matching those lims (plus some buffer)

        % Get appropriate range of data to plot
        range=[finder(lims(1),xD) finder(lims(2),xD)]; 
        range=round(min(max(range*[1.5 -0.5;-0.5 1.5],1),size(xD,1))); % Expand for cheap panning
        
        if diff(range)<magicnumber % If required range is small enough...
            % ain't worth ma' time!
            xP=xD(range(1):range(2));
            yP=cellfun(@(y)y(range(1):range(2)),yD,'uniformoutput',false);       
        elseif lims(1)<dlims(1) || lims(2)>dlims(2) || 2*diff(lims)<diff(dlims) % If re-subsampling is needed

                % Option 0: Make a subsampling vector, add random jitter to avoid aliasing.
%                 delta=(range(2)-range(1))/magicnumber;
%                 listvec=range(1):delta:range(2)-delta;
%                 listvec=floor(listvec+rand(size(listvec)) * delta+1);
                % Above approach was tried and was faster but sucked.
                % Especially bad for spiking data, where missed events can
                % make the data look completely different on each refresh.
                % Below approaches instead just sample min/max points.

                % Option 1: find a factor of the length that works nicely
                delta=floor((range(2)-range(1))/magicnumber);
                if isequal(range,[1 length(xD)]); % Save time,space on array reconstruction if full
                    f=factor(length(xD));
                    f=f(find((f<delta)&(f/2==round(f/2)),1,'last'));
                    if f>delta/3
                        xP=xD(range(1):f:range(2));
                        yP=cellfun(@(y)y(extremes(y,2*f)),yD,'uniformoutput',false);
                        option1fail=false;
                    else
                        option1fail=true;
                    end
                else
                    option1fail=true;
                end
                
                % Option 2: adjust the range a little and make the factor.
                if option1fail
                    % Option 2: Take mins, maxes for each pixel column
                    range(2)=range(1)+2*delta*floor((range(2)-range(1))/(2*delta))-1; % Round so 2*delta fits in
                    xP=xD(range(1):delta:range(2));
                    yP=cellfun(@(y)y((range(1)-1)+extremes(y(range(1):range(2)),2*delta)),yD,'uniformoutput',false);
                    
                end
                                
        else % Signal that no change is needed by nan'ing them
            xP=nan;
            yP=nan;

        end        
    end

%% Initial Plot

[xP yP]=getPoints(xD([1 end]),[0 0]);
hP=plot(xP,cell2mat(yP),varargin{:});
if nargout>0,varargout{1}=hP;end
drawnow;

%% Add axes-change listener
hL=addlistener(gca,'XLim','PostSet',@replot);


%% Callback function
    function replot(~,~)    
        % Callback for axes change: Problem: only want this executing when
        % event queue is flushed!
        s=dbstack;
        if length(s)<2 || ~any(strcmp(s(2).name,{'LocSetLimits','locDataPan'})), return; end
        
        if ~ishandle(hP(1)), delete(hL); return; end
        lims=get(get(hP(1),'parent'),'xlim');
        xP=get(hP(1),'xdata');
        [xP yP]=getPoints(lims,xP([1 end]));
        if ~isnan(xP)
            cellfun(@(hh,y)set(hh,'xdata',xP,'ydata',y),num2cell(hP)',yP);
        end
    end

end

function ixy=extremes(y,delta)
% return only the most extreme points in each size-delta bin of y.
% Assumption: delta divides evenly into length(y), y is a vector

if ~isvector(y); error('Ys gotta be a vector!'); end

y=reshape(y,delta,[]);

[~,ixmax]=max(y,[],1);
[~,ixmin]=min(y,[],1);
ix=sort([ixmax;ixmin],1);

ixy=sub2ind(size(y),ix(:),reshape(repmat(1:size(y,2),2,1),[],1));

end

function [loc found]=quickfind(el,list)
% loc=quickfind(el,list)
%
% Finds the index of an element el in a SORTED list really quick.
%
% It doesn't check if the list is sorted, because that would take O(N) time
% and this is meant to run in O(log(N)).  If you give it an unsorted list,
% it will either return a zero, and error, or the wrong answer.  It is
% guaranteed to stop though, which is nice.
%
% If you give it an element that's not in the sorted list, it will return a
% NEGATIVE number, which indicates the negative of the nearest smaller list
% element.  eg: quickfind(r(5144)+.00000001,r) returns -5144.  Special
% case: if it's smaller than the first element it returns zero.
%
% Example usage
% r=sort(rand(1,10000000));
% tic, quickfind(r(7654321),r), toc
%
% Have fun..
%
% Peter
% oconnorp -at- ethz -dot- ch



% If not in bounds, enforce the "negative nearest lower index" rule
if el<list(1), loc=0; found=false; return;
elseif el>list(end), loc=numel(list)+1; found=false; return;
end


n=100; 
% n should be at least 3 to work  Test show it's more or less the same from 
% 30 to 500, then it starts sucking for bigger numbers.
    
st=1;
en=numel(list);
while true
    
    ix=ceil(linspace(st,en,n));
    
    i=find(el<=list(ix),1);
    
    if el==list(ix(i))
        loc=ix(i);
        found=true;
        return;
    else
        st=ix(i-1); en=ix(i);        
        if (en-st)<2 && st~=el,
            % It's not in the list, or the list ain't sorted
            loc=(el-list(st))/(list(en)-list(st))+st;
            found=false;
            return;
        end            
    end    
end
end