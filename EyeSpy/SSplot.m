function varargout=SSplot(X,classes,varargin)
% Plots a 3-D subpspace of a series of points.  Includes a control allowing
% you to select which dimensions to plot
%
% X is a data matrix, where rows are samples, columns are dimensions
% classes is an optional array of class labels

if ~exist('classes','var')||isempty(classes), classes=ones(size(X,1),1); end

u=unique(classes);

d=[1 2 3];


    function replot
        hold off
        for i=1:length(u)
            scatter3(X(classes==u(i),d(1)),X(classes==u(i),d(2)),X(classes==u(i),d(3)),varargin{:});
            hold all;
        end
        
    end

replot

% Make a button
U=UIlibrary;
hB=U.addbuttons('ddd');
set(hB,'string',sprintf('dims(%g,%g,%g)',d(1),d(2),d(3)));
set(hB,'callback',@(e,s)redim);

    function redim
        
        res=inputdlg('Enter 3-Dimensions');
        if isempty(res), return; end
        
        dpot=str2num(res{1});
        
        if length(dpot)~=3 || any(dpot~=round(dpot) | dpot<1 | dpot>size(X,2))
            errordlg('Must input 3 dimensions, that actually fit');
            return; 
        end
        
        set(hB,'string',sprintf('dims(%g,%g,%g)',d(1),d(2),d(3)));
        
        d=dpot;
        replot;      
    end


if nargout>0
   varargout{1}=h; 
end

grid on

end