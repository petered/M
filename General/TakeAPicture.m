function TakeAPicture(varargin)
% Create and save a png picture from your figure.
%
% e.g. 
% TakeAPicture                                    % Take a picture
% TakeAPicture -inv                               % Take a picture and invert the colors
% TakeAPicture -auto                              % Use a default name and directory
% TakeAPicture('name','aaa','manualcrop',false)   % Specify the name and don't crop
% TakeAPicture('-withfig','name','aaa')           % Also save the .fig file and specify the name 
% TakeAPicture('-withfig','colors','inv')         % Also save the .fig file and invert colors
%
% Settings (enter as property-value pairs)
% 'name'        : Name of picture (default: <timestamp>)
% 'destination' : Save location (default: cd)
% 'figure'      : Figure handle (default: gcf)
% 'invert'      : whether to invert (default: false)
% 'figsave'     : whether to also save the figure (default: false)
% 'uidir'       : whether to use user-selected directory (default: true)
% 'manualcrop'  : whether to manually crop the image (default: true)
% 'hidecontrols': whether to hide ui controls (default: false)
% 'colors'      : how to modify colors. Make a cell array to do multiple 
%                 operations.  Options are:
%                   'inv'       : invert colors
%                   'grey'      : sets colors to greyscale
%                   'bw'        : black and white
%                   'decolor'   : greys out the extreme colors.
%                   'normal'    : does nothing
%
% Enjoy
% -Peter


%% Input Grabbing



% Default settings

set(0,'showhiddenhandles','on');
h=get(0,'currentfigure');
set(0,'showhiddenhandles','off');

if isempty(h), disp 'No Figure Open!'; return; end
name='';
direct=cd;
figsave=false;
manualcrop=true;
uidir=true;
colors='normal';
hidecontrols=false;

% Batch settings
if ~isempty(varargin) && varargin{1}(1)=='-'
    settings=varargin{1};
    varargin=varargin(2:end);
else
    settings='-default';
end

if ismember('-leavelines',varargin)
    leavelines=true;
else
    leavelines=false;
end


switch settings
    case '-auto'
        uidir=false;
        manualcrop=false;        
    case '-nocrop'
        manualcrop=false;        
    case '-inv'
        colors='inv';        
    case '-withfig'
        figsave=true;
    case '-good'
        colors={'inv','decolor'};
        hidecontrols=true;
    case '-report'
        [name defdir]=uiputfile('*.pdf',direct);
        if ~name, return; end
        fprintf('Saving original file...')
        figname=[name(1:find(name=='.',1,'last')) 'fig'];
        saveas(h,figname);
        hnew=h;
%         hnew=copyobj(h,0); 
        if prod(get(hnew,'color'))==prod([0.35 0.35 0.35])
            invertcols(hnew,[],leavelines);
        end
        
        invertcols(hnew,@(c)(c+mean(c))/2,leavelines);
        cd(defdir)
        filename=sprintf('%s%s%s',cd,filesep,name);
        fprintf('Saving file...');
        saveas(hnew,filename);
        fprintf('Done: <a href="matlab:open(''%s'')">%s</a>\n',filename,filename);;
%         delete(hnew);
        return;
        
    case '-oldreport'
        switch prod(get(gcf,'color'))
            case prod([0.35 0.35 0.35]) % colordef black
                colors={'inv','decolor'};
            otherwise % colordef white
                colors={'decolor'};
        end
        hidecontrols=true;
        figsave=true;        
        
    case '-lazy'
        direct='/users/oconnorp/Desktop/Figures/Cool Pics/auto';
        colors={'inv','decolor'};
        hidecontrols=true;
        uidir=false;
        manualcrop=false;           
    case '-default'
    otherwise
        error('No batch command "%s" has been made yet.  Make one here.',settings);
end

% Individual parameter setting
for i=1:2:length(varargin)
    switch varargin{i}
        case 'name'
            name=varargin{i+1};
        case 'destination'
            direct=varargin{i+1};
        case 'figure'
            h=varargin{i+1};
        case 'figsave'
            figsave=varargin{i+1};
        case 'uidir'
            uidir=varargin{i+1};
        case 'manualcrop'
            manualcrop=varargin{i+1};
        case 'colors'
            colors=varargin{i+1};
        case 'hidecontrols'
            hidecontrols=varargin{i+1};
    end
end

%% Getting 'er done

% Hide UI controls
if hidecontrols
    hUI=get(h,'children');
    hUI=hUI(strcmp(get(hUI,'type'),'uicontrol'));
    set(hUI,'visible','off');   
end

% Do cropping
if manualcrop
   zoom off;
   pan off;
   rotate3d off;
   
   % Setup
   oldp=get(h,'Pointer');
   oldb=get(h,'ButtonDownFcn');
   
   % Crop
   set(h,'Pointer','fullcrosshair');
   set(h,'ButtonDownFcn','uiresume;');
   uiwait(h)
   
   if ~ishandle(h)
       disp 'Snapshot Aborted'
       return;
   end
   
   p1=get(h,'CurrentPoint');
   uiwait(h)
   p2=get(h,'CurrentPoint');
   
   % Restore
   set(h,'Pointer',oldp);
   set(h,'ButtonDownFcn',oldb);
   
   rect=[min([p1;p2]) max([p1;p2])-min([p1;p2])];
   
   F=getframe(gcf,rect);
else
    F=getframe(gcf);
end

% Re-show UI controls
if hidecontrols
    set(hUI,'visible','on');
end

% Modify Colors
if ~iscell(colors), colors={colors}; end
for i=1:length(colors)
    switch colors{i}
        case 'inv'
            F.cdata=255-F.cdata;
        case 'grey'
            F.cdata=uint8(repmat(mean(F.cdata,3),[1,1,3]));
        case 'bw'
            F.cdata=uint8(repmat(255*round(mean(F.cdata,3)/255),[1,1,3]));            
        case 'decolor'
            F.cdata=uint8((double(F.cdata)+repmat(mean(F.cdata,3),[1 1 3]))/2);
        case 'normal'
        otherwise
            error('Don''t know this "%s" color operation.',colors{i});
    end
end

% Get Directory
if ~isdir(direct)
    mkdir(direct);
end
cd (direct);
if uidir
    [name defdir]=uiputfile('*.png',direct);
    if ~name, return; end
    cd(defdir)
end
    
% Make a filename
if ~isempty(name), filename=name;
else s=clock;    
    filename=[int2str(s(1)) '-' int2str(s(2)) '-' int2str(s(3)) '  '...
        int2str(s(4)) '.' int2str(s(5)) '.' num2str(s(6)) '.png'];
end


% Save
% imwrite(F.cdata,filename,'tiff','compression','lzw');

imwrite(F.cdata,filename,'png');
fprintf('Image saved in "%s%s%s"\n',direct,filesep,filename);

% cd(direct)
if figsave
    figname=[filename(1:find(filename=='.',1,'last')) 'fig'];
    saveas(h,figname);
    fprintf('Figure saved in "%s%s%s"\n',direct,filesep,figname);
end
end
