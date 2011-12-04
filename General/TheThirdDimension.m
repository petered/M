function TheThirdDimension(mat,lims,initialcoords,hAx,varargin)
% Interactive plot of a 3-D matrix.  Click each plot to adjust the indexing
% of the other.
%
% eg: 
% mat=randn(20,20,100);
% TheThirdDimension(mat);
%
% mat - the 3-d matrix
% lims - 3x2 vector of data limits
% initialcoords - 3 coordinates indicating the initial planes to plot
% hAx (optional) - Two axes handles indicating where to plot
%
%

%% Input Parsing

% Lims
if ~exist('lims','var')||isempty(lims)
   lims=[1 1 1;size(mat)]';
end

% InitialCoords
if ~exist('initialcoords','var')||isempty(initialcoords)
    initialcoords=round(mean(lims,2))';
elseif length(initialcoords)~=3
    error('Must provide 3 initial coordinates!');
end

% Axes
if ~exist('hAx','var')
    figure;
    hAx(1)=subplot(1,2,1);
    hAx(2)=subplot(1,2,2);
end
    
% Other Arguments
xcolor='k';
pcolor=[.5 .5 .5];
for ii=1:2:(length(varargin)-1)
   switch lower(varargin{ii})
       case  'xcolor', xcolor=varargin{ii+1};
       case  'pcolor', pcolor=varargin{ii+1};
   end
end
    

%% Ger 'er done
    

y=initialcoords(1);
x=initialcoords(2);
i=initialcoords(3);


% Initialize handles
hL1=[nan nan];
hL2=nan;
hI=nan;
hP=nan;

zvec=linspace(lims(3,1),lims(3,2),size(mat,3));

function ix=coord2ix(coord,dim)
    ix=((coord-lims(dim,1))/(lims(dim,2)-lims(dim,1))) * (size(mat,dim)-1)+1;
    ix=min(max(round(ix),1),size(mat,dim));
end

function coord=ix2coord(ix,dim)
    coord=lims(dim,1)+(ix-1)/(size(mat,dim)-1)*(lims(dim,2)-lims(dim,1));
end

function redoX
    % Plot the crosshoirs
    subplot(hAx(1));
    delete(hL1(ishandle(hL1)));
    hL1=addline([ix2coord(x,2) ix2coord(y,1)],'vh','LineWidth',2,...
        'LineStyle',':','color',xcolor,'HitTest','off');
    
end

function redoV
    % Plot the vertical line
    subplot(hAx(2))
    delete(hL2(ishandle(hL2)));
    hL2=addline(zvec(i),'LineWidth',2,'LineStyle',':','HitTest','off');
end

function imCB(s,~) % When the image is clicked...

    if s~=0 % not initial
        P=get(s,'CurrentPoint');
        x=coord2ix(P(1,1),2);
        y=coord2ix(P(1,2),1);
    end

    % Plot the new line
    subplot(hAx(2))
    delete(hP(ishandle(hP)));
    hP=plot(zvec,squeeze(mat(y,x,:)),'color',pcolor,'HitTest','off');
    if s==0
        hold on;
    else
        redoX;
    end

    

end

function plotCB(s,~) % When the plot is clicked...

    if s~=0 % not initial
        P=get(s,'CurrentPoint');
        i=coord2ix(P(1),3);
    end

    % Plot the new image
    subplot(hAx(1));
    delete(hI(ishandle(hI)));
    hI=imagesc(lims(2,:),lims(1,:),mat(:,:,i),'HitTest','off');        
    set(hAx(1),'children',circshift(get(hAx(1),'children'),[-1,0]));

    if s==0
        set(hAx(1),'clim',[min(mat(:)) max(mat(:))]);
        hold on;
%         colorbar;
    else
        redoV;
    end



end

% Make initial plots and set callbacks
imCB(0)
plotCB(0);
redoX;
redoV;
set(hAx(1),'ButtonDownFcn',@imCB);
set(hAx(2),'ButtonDownFcn',@plotCB);





end