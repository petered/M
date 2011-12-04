classdef Viewer < handle
% Allows you to easily create a user-interface to an object in the
% base-workspace.  This is nice, because usually user-interfaces only work
% at run-time, so if you have an error or something you have to start from
% scratch.  
%
% Intended to be used as a superclass
%
% Usage: start with subclass "Example"
% E=Example; E.Start
%
%
% Peter O'Connor
% oconnorp .at. ethz .dot. ch

    
    
    properties
        
        % Things for user to tweak
        saveprompt=false;   % Boolean: Prompt user to save?        
        modified=false;     % Boolean have any observable properties been modified since save?
        startprompt=true;   % Initial prompt about whether to load or create
        startmethod='StartUp' % Called after running "Start" method
        loadmethod='LoadUp'   % Called after running "Load" method
        
    end
    
    properties (SetObservable)
                
        saveloc;            % Name and path of file to save
        % * note: saveloc is the only observable property whose change does
        % not set "modified" to true.
    end
    
    properties (Hidden=true)
        
        hMENU               % Handle of Menu        
        varname;            % Name under which to save variable.  Auto-set to base-workspace name of object.
                
        % Not so important
        options;            % Options for display on menu.  OBSOLETE, here for backcompatibilty        
        F;                  % Link to UILibrary, if you have it
        IDname='(Unnamed)'; % May be pointless, but may be used in future
        
    end
    
    methods % Get/Set Methods
        
        function F=get.F(A)
            if isempty(A.F)
                if exist('UILibrary.m','file')
                    A.F=UILibrary;
                end
            end
            F=A.F;
        end
        
        function set.saveloc(A,loc)
            A.saveloc=loc;
            if isempty(loc) , return; end
                        
            [garb A.IDname]=fileparts(loc);
        end
        
        function set.options(A,val)
            
            if ~iscell(val), error('Options property must be a cell array of strings.'); end
           
            A.options=val;
            
        end
        
        function set.IDname(A,val)
            
            A.IDname=regexprep(val,{'\' '/' ':' '?' '*' '"' '<' '>' '|'},'-');
            
        end
        
    end
    
    methods % Core Functions
        
        function RunOption(A,option)
            % Runs the option... If the option
            
            try 
%                 set(A.hMENU,'HandleVisibility','off');
                close all; 
            
                % Run the damn thing
                A.(option);
                
                    
%                 set( A.hMENU,'HandleVisibility','on');
                
            catch ME, 
                if strcmp (ME.identifier,'MATLAB:badSwitchExpression'), 
                    return; 
                else
                    msglist={'You broke it!',...
                        'You''ve really done it this time..',...
                        'Huge, HUGE error',...
                        '0x5436 Fatal System Crash',...
                        'Overheated function',...
                        'Please replace user and try again.'...
                        'Dumping virtual, real, and imaginary memory...',...
                        'Deleting CPU...',...
                        'Poor use of code',...
                        'Demagnetizing Hard Drive',...
                        'Remagnetizing Hard Drive',...
                        'The user has sinned',...
                        'Show has been cancelled',...
                        'Error due to union regulations'...
                        };
                    
                    msg=sprintf('ERROR:\n--------------\nfunction: %s\n\nline: %g\n\nmessage: %s\n--------------\nSee Command Line for details',...
                        ME.stack(1).name,ME.stack(1).line,ME.message);
                    
                    errordlg(msg, msglist{ceil(length(msglist)*rand)});     
                    
                    rethrow(ME);
                end, 
            end
            
            
        end
        
        function menuFig=menu4(A, xHeader, xcItems, pretty, basespace, snapshot,optionarray)
            % local function to display a Handle Graphics menu and return the user's
            % selection from that menu as an index into the xcItems cell array
            % Modified by Peter
            %
            %=========================================================================
            % SET UP
            if ~exist('xcItems','var')||isempty(xcItems), xcItems=A.options; end
            if ~exist('pretty','var'), pretty=true; end
            if ~exist('basespace','var')||isempty(basespace), basespace=true; end
            if ~exist('snapshot','var')||isempty(snapshot), snapshot=false; end
            if ~exist('optionarray','var'), optionarray={}; end
            
            xcItems=xcItems(:);
            
            %=========================================================================
            % Set spacing and sizing parameters for the GUI elements
            %-------------------------------------------------------------------------
            
            
            
            MenuUnits   = 'pixels'; % units used for all HG objects
            textPadding = [22 12];   % extra [Width Height] on uicontrols to pad text
            uiGap       = 5;       % space between uicontrols
            uiBorder    = 10;       % space between edge of figure and any uicontol
            winTopGap   = 60;       % gap between top of screen and top of figure **
            winWideMin  = 140;      % minimin window width necessary to show title
            
            st=dbstack;
            if length(st)<2 || strcmp(st(2).name,[mfilename('class')  '.menu'])
                winLeftGap  = 200;       % gap between side of screen and side of figure **
            else 
                winLeftGap  = 200+winWideMin+20;
            end
            

            % ** "figure" ==> viewable figure. You must allow space for the OS to add
            % a title bar (aprx 42 points on Mac and Windows) and a window border
            % (usu 2-6 points). Otherwise user cannot move the window.

            
            %-------------------------------------------------------------------------
            % Calculate the number of items in the menu
            %-------------------------------------------------------------------------
            
            
            
            
            

            %=========================================================================
            % BUILD
            %=========================================================================
            % Create a generically-sized invisible figure window
            %------------------------------------------------------------------------
            menuFig = figure( 'Units'       ,MenuUnits, ...
                              'Visible'     ,'off', ...
                              'NumberTitle' ,'off', ...
                              'Name'        ,'MENU', ...
                              'Resize'      ,'off', ...
                              'Colormap'    ,[], ...
                              'Menubar'     ,'none',...
                              'Toolbar'         ,'none', ...
                              'IntegerHandle','off'...
                               );



            %------------------------------------------------------------------------
            % Add generically-sized header text with same background color as figure
            %------------------------------------------------------------------------
            hText = uicontrol( ...
                    'style'       ,'text', ...
                    'string'      ,xHeader, ...
                    'units'       ,MenuUnits, ...
                    'Position'    ,[ 100 100 100 20 ], ...
                    'Horizontal'  ,'center',...
                    'BackGround'  ,get(menuFig,'Color'),... 
                    'ForegroundColor',round(1-get(menuFig,'Color'))...
                );

                        
            % Record extent of text string
            maxsize = get( hText, 'Extent' );
            textWide  = maxsize(3);
            textHigh  = maxsize(4);

            %------------------------------------------------------------------------
            % Add generically-spaced buttons below the header text
            %------------------------------------------------------------------------
            % Loop to add buttons in reverse order (to automatically initialize numitems).
            % Note that buttons may overlap, but are placed in correct position relative
            % to each other. They will be resized and spaced evenly later on.

            
            % Seperate the displayed items (dispItems) from the actual
            % function calls asscociated with them (xcItems), because
            % sometimes they're different.
            dispItems=xcItems;
            ixcell=cellfun(@iscell,xcItems);
            dispItems(ixcell)=cellfun(@(x)x{1},xcItems(ixcell),'UniformOutput',false);
            xcItems(ixcell)=cellfun(@(x)x{2},xcItems(ixcell),'UniformOutput',false);
            if pretty, dispItems=regexprep(dispItems,'_',' '); 
            else dispItems=xcItems;
            end
            
            
            % Deal with the snapshot thing
            if snapshot
                xcItems=[xcItems; {@(src,evnt)A.snapshot}];
                dispItems=[dispItems; '< Take A Picture >'];
                
                xcItems=[xcItems; {@(src,evnt) A.Give_Me_A_Break }];
                dispItems=[dispItems; '>>Command Line'];
            end
            
            
            
            % Add extra menu options
            for i=1:2:length(optionarray)
                if ~ischar(optionarray{i})
                    error('Extra Arguments must be entered in format: ''name'', callback, where "callback" is a function handle');
                end
                
                dispItems=[dispItems; optionarray{i}]; %#ok<AGROW>
                xcItems=[xcItems; {@(src,evnt)evalin('base',optionarray{i+1})}]; %#ok<AGROW>
            end
            
            
            numItems = length( xcItems );
            hBtn = zeros(numItems, 1);
            for idx = numItems : -1 : 1; % start from top of screen and go down
                n = numItems - idx + 1;  % start from 1st button and go to last
                
                if ischar(xcItems{n})
                    hBtn(n) = uicontrol( ...
                               'units'          ,MenuUnits, ...
                               'position'       ,[uiBorder uiGap*idx textHigh textWide], ...
                               'callback'       , @(evnt,src) A.RunOption(xcItems{n}), ...
                               'string'         , dispItems{n} ,...
                               'tooltip'        , help([class(A) '>' xcItems{n}])  );
                elseif isa(xcItems{n},'function_handle')
                    hBtn(n) = uicontrol( ...
                               'units'          ,MenuUnits, ...
                               'position'       ,[uiBorder uiGap*idx textHigh textWide], ...
                               'callback'       , xcItems{n}, ...
                               'string'         , dispItems{n} );
                end

            end % for

            
            if ~ismac % Because it looks like shit on mac
                bgcol=get(gcf,'Color');
                set(hBtn,'BackgroundColor',bgcol,'ForegroundColor',round(mod(bgcol+0.5,1)));                
            end
            
            try
            RandStream.setDefaultStream(RandStream('swb2712','seed',cputime*1000));
            catch %#ok<CTCH>
            end
            
            if rand<.01
%                 set(gcf,'color',[rand rand rand],'WindowButtonMotionFcn',@(evnt,src)set(menuFig,'color',hsv2rgb(mod(rgb2hsv(get(menuFig,'color'))+[.01*rand 1 0],1))));
                set(gcf,'color',[rand rand rand],'WindowButtonMotionFcn',@(evnt,src)set(menuFig,'color',hsv2rgb(mod(get(menuFig,'color')+.5,1))));
                for i=1:length(hBtn)
                    bgcol=rand(1,3);
                    set(hBtn(i),'BackgroundColor',bgcol,'ForegroundColor',round(mod(bgcol+0.5,1)));
                end
            end
            
            %=========================================================================
            % TWEAK
            %=========================================================================
            % Calculate Optimal UIcontrol dimensions based on max text size
            %------------------------------------------------------------------------
            cAllExtents = get( hBtn, {'Extent'} );  % put all data in a cell array
            AllExtents  = cat( 1, cAllExtents{:} ); % convert to an n x 3 matrix
            maxsize     = max( AllExtents(:,3:4) ); % calculate the largest width & height
            maxsize     = maxsize + textPadding;    % add some blank space around text
            btnHigh     = maxsize(2);
            btnWide     = maxsize(1);

            %------------------------------------------------------------------------
            % Retrieve screen dimensions (in correct units)
            %------------------------------------------------------------------------
            screensize = get(0,'ScreenSize');  % record screensize

            %------------------------------------------------------------------------
            % How many rows and columns of buttons will fit in the screen?
            % Note: vertical space for buttons is the critical dimension
            % --window can't be moved up, but can be moved side-to-side
            %------------------------------------------------------------------------
            openSpace = screensize(4) - winTopGap - 2*uiBorder - textHigh;
            numRows = min( floor( openSpace/(btnHigh + uiGap) ), numItems );
            if numRows == 0; numRows = 1; end % Trivial case--but very safe to do
            numCols = ceil( numItems/numRows );

            %------------------------------------------------------------------------
            % Resize figure to place it in top left of screen
            %------------------------------------------------------------------------
            % Calculate the window size needed to display all buttons
            winHigh = numRows*(btnHigh + uiGap) + textHigh + 2*uiBorder;
            winWide = numCols*(btnWide) + (numCols - 1)*uiGap + 2*uiBorder;

            % Make sure the text header fits
            if winWide < (2*uiBorder + textWide),
                winWide = 2*uiBorder + textWide;
            end

            % Make sure the dialog name can be shown
            if winWide < winWideMin %pixels
                winWide = winWideMin;
            end

            % Determine final placement coordinates for bottom of figure window
            bottom = screensize(4) - (winHigh + winTopGap);

            % Set figure window position
            set( menuFig, 'Position', [winLeftGap bottom winWide winHigh] );

            %------------------------------------------------------------------------
            % Size uicontrols to fit everyone in the window and see all text
            %------------------------------------------------------------------------
            % Calculate coordinates of bottom-left corner of all buttons
            xPos = ( uiBorder + (0:numCols-1)'*( btnWide + uiGap )*ones(1,numRows) )';
            xPos = xPos(1:numItems); % [ all 1st col; all 2nd col; ...; all nth col ]
            yPos = ( uiBorder + (numRows-1:-1:0)'*( btnHigh + uiGap )*ones(1,numCols) );
            yPos = yPos(1:numItems); % [ rows 1:m; rows 1:m; ...; rows 1:m ]

            % Combine with desired button size to get a cell array of position vectors
            allBtn   = ones(numItems,1);
            uiPosMtx = [ xPos(:), yPos(:), btnWide*allBtn, btnHigh*allBtn ];
            cUIPos   = num2cell( uiPosMtx( 1:numItems, : ), 2 );

            % adjust all buttons
            set( hBtn, {'Position'}, cUIPos );

            %------------------------------------------------------------------------
            % Align the Text and Buttons horizontally and distribute them vertically
            %------------------------------------------------------------------------

            % Calculate placement position of the Header
            textWide = winWide - 2*uiBorder;

            % Move Header text into correct position near the top of figure
            set( hText, ...
                 'Position', [ uiBorder winHigh-uiBorder-textHigh textWide textHigh ] );

            %=========================================================================
            % ACTIVATE
            %=========================================================================
            % Make figure visible
            %------------------------------------------------------------------------
            set( menuFig, 'Visible', 'on' );
                        
            set( menuFig, 'HandleVisibility', 'off' );
            

            %------------------------------------------------------------------------
            % Wait for choice to be made (i.e UserData must be assigned)...
            %------------------------------------------------------------------------
            if ~basespace
                while 1

                    waitfor(menuFig,'userdata')

%                     ------------------------------------------------------------------------
%                     Selection has been made or figure has been deleted. 
%                     Assign k and delete the Menu figure if it is still valid.
%                     ------------------------------------------------------------------------
                    if ishandle(menuFig)
                         k = get(menuFig,'userdata');
                        delete(menuFig)
                    else
                    %     % The figure was deletd without a selection. Return 0.
                         k = 0;
                    end

%                     evalin('base',callmeback{k});

%                    set(menuFig,'HandleVisibility','off');
                   
%                     delete(menuFig);
                    
                    menuFig=k;
                   
                   return;

                end
          end 
           function menucallback(btn, evd, index, objname)                                 %#ok
                set(gcbf, 'UserData', index);

    %             evalin('base',['eval( ' objname '.CBoptions{' int2str(index) '})']);
                evalin('base',['eval(' objname '.CBoptions{' int2str(index) '});']);

           end
               
           delete(A.hMENU(ishghandle(A.hMENU)));
           A.hMENU=menuFig;
           A.addFileMenu;

        end
        
        function Start(A)
            
            A.varname=inputname(1);
            A.setListeners;
                        
            if A.startprompt
                res=questdlg(sprintf('Create a new %s object or load an existing one?',class(A)),...
                    class(A),'Create','Load','Cancel','Create');
                switch res
                    case 'Create'
                        A.(A.startmethod);
                    case 'Load'
                        A.Load;
                end
            else % JustCreate
                A.(A.startmethod);
            end
                        
        end
        
        function StartUp(A) %#ok<MANU>
            % Empty - basically an abstract method, but it exists here as
            % an ordinary method so it doesn't cause an error if undefined
            % in the subclass.            
            
            
        end
                          
        function LoadUp(A) %#ok<MANU>
            % Here for the same reason as startup.
            
        end
        
        function FileInfo(A)
            % Feel free to subclass this bi-hatch if you want a more
            % complete description of the object.
            
            if A.modified
                mod='yes';
            else
                mod='no';
            end
            
            txt=sprintf([...
                'Variable name:       %s\n'...
                'Save Location:       %s\n'...
                'Changed since save?  %s\n'],A.varname,A.saveloc,mod);
            
            helpdlg(txt,'File Info');
            
        end
                
        function menu(A,tit,pretty,varargin) % Sort of obsolete, but, you know, backcompatibility and all...
            
            colordef black;
            
            if ~exist('tit','var'),tit=A.IDname; end
            if ~exist('pretty','var'),pretty=true; end
            
            obj=inputname(1);
            
            if isempty(A.options),
                A.options=setdiff(methods(A),[methods('Viewer');class(A)]);
            end
            
%             A.CBoptions=strcat('try set(', obj, '.hMENU,''HandleVisibility'',''off'');',...
%                 'close all; ', obj, '.',A.options,';set( ', obj, '.hMENU,''HandleVisibility'',''on'');',...
%                 'catch ME, if strcmp (ME.identifier,''MATLAB:badSwitchExpression''), return; else rethrow(ME); end, end');
            
%             if pretty
%                 dispoptions=regexprep(A.options,'_',' ');
%             else 
%                 dispoptions=A.options;
%             end
            
%             A.hMENU=menu3(tit,dispoptions,obj);
            A.hMENU=A.menu4(tit,[],pretty,true,true,varargin);
            
        end
        
        function addFileMenu(A,toFigure)
            
            if ~exist('toFigure','var')
                toFigure=A.hMENU;
            end
            
            hf=uimenu(toFigure,'Label','File');
            uimenu(hf,'Label','New',        'callback',@(e,s)A.New);
            uimenu(hf,'Label','Load',       'callback',@(e,s)A.Load);
            uimenu(hf,'Label','File Info',  'callback',@(e,s)A.FileInfo,'Separator','on');
            uimenu(hf,'Label','Save',       'callback',@(e,s)A.Save);
            uimenu(hf,'Label','Save As...', 'callback',@(e,s)A.Save_As);
            uimenu(hf,'Label','Save Copy',  'callback',@(e,s)A.Save_Copy);
            uimenu(hf,'Label','Close',      'callback',@(e,s)A.Close,'Separator','on');
            
        end
        
        function name=filename(A)
            % Return the file name sans extenstion
            if ischar(A.saveloc)&&~isempty(A.saveloc)
                [~,name]=fileparts(A.saveloc);
            else
                name='<un-named>';
            end
        end
        
    end
    
    methods % Options that can be added to menu
        
        function New(A)
            n=A.varname; c=class(A);
            evalin('base',['close all hidden; ' n '=' c '; ' n '.Start;']);
        end
        
        function Save_As(A)
            % Save this object in a new location
            A.saveloc=[];
            A.Save;
        end
        
        function Save_Copy(A)
            
            A.Save([],true);
            
        end
        
        function Save(A,loc,keepmaidenname)
            % Save this object
            
            if ~exist('keepmaidenname','var'), keepmaidenname=false; end
            if isempty(A.varname), A.varname='A'; end
            
            % Get Loc            
            if (~exist('loc','var') && isempty(A.saveloc)) || keepmaidenname
                [FileName,PathName] = uiputfile('*.mat','Save Location');
                if ~FileName
                    disp 'Save Cancelled';
                    return;
                end
                loc=[PathName FileName];
            elseif ~exist('loc','var')
                loc=A.saveloc;
            end
                
            
            if keepmaidenname
                fprintf 'Copy of ';
            else
                A.saveloc=loc;
            end            
            
            eval([A.varname '=A;']);
            save(loc,A.varname);
            A.modified=false;
            
            
            fprintf ('Object saved in:\n  "%s"\n',loc);
            
        end
        
        function loc=Load(A,loc)
            % Load a new object of this class.
            
            persistent path
            if ischar(path)&&isdir(path), cd (path); end
                                    
            
            if ~exist('loc','var')
                [name path]=uigetfile('*.mat','Select Experiment To Load...');
                % Allow option to cancel if nothing loaded or "cancel" clicked
                if isequal(name,0) || A.SavePrompt;
                    disp 'Load Cancelled'
                    return;
                end
                loc=[path name];
            end
            
            % Kill the old object and create a new one
%             if ishandle(A), delete(A,true); end            
%             eval(['A=' clname ';']);       
                                


            % Look for object in file
            A.resetPrompt(false); % Work-around for strange problem where whose call the delete function
            list=whos('-file',loc);
            
            f=find(strcmp({list.class},class(A)));
            switch length(f)
                case 0
                    error('No Object of class "%s" found in file \n  "%s"',class(A),loc);
                case 1
                    ix=f;
                otherwise
                    k=menu(sprintf('Multiple object of class "%s" found.  Pick one.',class(A)),{list.name});
                    ix=f(k);
            end
            
%             % Get object name, set up starting command
            name=list(ix).name;
%             if ~exist('startmethod','var')||isempty(startmethod), 
%                 startmethod=[name '.StartUp;']; 
%             else
%                 startmethod=[name '.' startmethod ';'];
%             end
%             
%             % Load object and clear previous menus

            % Fuckin' DO IT
            cancel= A.SavePrompt;
            if cancel, return; end
            
            FILE=load(loc,name);
            B=FILE.(name);
            pB=properties(B);
            fprintf('Loading Object...')
            for i=1:length(pB)
                A.(pB{i})=B.(pB{i});
            end
            disp Done
            
            
            
            
            
            A.modified=false;
            
            A.(A.loadmethod);
%             
            clearvars -except A
            A.resetPrompt(true);

%             p=propertiis
% 
% 
%             evalin('base',['load ''' loc ''' ' name  '; ' name '.saveloc=''' loc ''';'...
%                 'close all hidden; '  name '.setListeners;' ...
%                 name '.' A.loadmethod '; ' name '.modified=false;']);
%             
%             evalin('base',['load ''' loc ''' ' name  '; ' name '.saveloc=''' loc '''; close all hidden;']);
            
        end
        
        function cancelled=Close(A)
            % Close this menu and delete the object
            
            cancelled=A.SavePrompt;
            if cancelled, return; end
            
            % Otherwise, continue with the destruction!
            A.saveprompt=false; % To stop delete from doing the same prompt
            vname=A.varname; % Catch it before it dies
            A.delete;
            evalin('base',['clear ' vname]);
            
        end
        
        function cancelled=SavePrompt(A)
            
            cancelled=false;
            if A.saveprompt && A.modified
                
                res=questdlg('Wanna save this one first?','Save?','Yes','No','Cancel','Yes');
                
                switch res
                    case 'Yes'
                        A.Save;                
                    case 'Cancel'
                        disp 'Cancelled.'
                        cancelled=true;
                        return;
                end
            end
            
        end
        
        function snapshot(A)

            persistent location cropyn;
            if isempty(cropyn), cropyn='n'; end
            if isempty(location), location='C:\Documents and Settings\Peter\My Documents\Peter\Presentations\ScreenShots'; end

            
            figs=get(0,'Children');
            if isempty(figs),return; end
            figure(figs(end));

            res=inputdlg({'Name:','Location:','Crop? (y/n)'},'Snapshot',1,{A.IDname location cropyn});
            location=res{2};
            cropyn=res{3};
            if isempty(res), return; end

            switch res{3}
                case 'y'
                    crop=true;
                otherwise
                    crop=false;
            end

            kids=get(gcf,'children');
            uis=kids(strcmp(get(kids,'type'),'uicontrol'));
            set(uis,'Visible','off');
            TakeAPicture(res{1},[],location,crop);
            set(uis,'Visible','on');

        end
           
    end
    
    methods % More File I/O stuff
        
        function setListeners(A)
            % Setup Observable Property Callbacks
            Ap=metaclass(A);
            j=1;
            
            for i=1:length(Ap.Properties)
                if Ap.Properties{i}.SetObservable %&& ~strcmp(Ap.Properties{i}.Name,'saveloc')
                    addlistener(A,Ap.Properties{i}.Name,'PostSet',@(src,evnt)A.IchangedIt);
                    j=j+1;
                end
            end
        end
        
        function IchangedIt(A)
            A.modified=true;            
        end
                
        function loadObj(A)
            A.setListeners;
        end
        
        function delete(A)
            
            if ishghandle(A.hMENU), delete(A.hMENU); end
            if A.resetPrompt
                if A.saveprompt && A.modified
                    res=questdlg(['Want to save the changes to this ' class(A) ' object before it goes?'],'Save?','Yes','No','No');
                    switch res
                        case 'Yes'
                            A.Save;
                        case 'Cancel'
                            disp 'Load Cancelled.'
                            return;
                    end

                end
                disp ([class(A) ' Object Deleted']);
            end
        end
        
    end
        
    methods % Fancy Extra Stuff 
        
        function KeyHandler(A,src,evnt)
            
            switch evnt.Key
                case 'p',
                    A.snapshot;
                    
            end
            
            
            
        end
        
    end
        
    methods (Static=true) % Fancy Extra Static Stuff (can also be added to menu)
        
        function Give_Me_A_Break(prompt) %#ok<INUSD>
            
            clc
            nl=sprintf('\n');
            if ~exist('prompt','var'), 
                prompt=['-------------------------------' nl ...
                'You made the right choice.  You can view/modify function ' nl...
                'variables from here.  Click <a href="matlab: figure(gcf);dbcont; ">here</a> '...
                'or type "return", to ' nl 'resume the program.']; %#ok<NASGU>
            end
            
            disp(['========================================' nl ...
                'Welcome to debug mode.  Click <a href="matlab: disp(prompt);dbup;dbup;">here</a> '...
                'to enter the workspace ' nl 'of the currently running function. ' nl 'Or '...
                '<a href="matlab: figure(gcf);dbcont;">here</a> to cower away from the '...
                'actual code and go back ' nl 'to all the pretty buttons and pictures']);
            keyboard; 
            
            

        end
        
        function export(varargin)
            % Tool for exporting variables to workspace
            
            names=cell(1,length(varargin));
            for i=1:length(varargin)
               names{i}=inputname(i);
            end
            
            h=export2wsdlg(names,names,varargin);
            uiwait(h);
            
        end
        
        function pr=resetPrompt(sr)
            % Allows the prompt to be turned off in the bizarre case where
            % use of "whos" calls the delete function.
            % p=true: allow prompts.  p=false: disable
            persistent p
            if isempty(p), p=true; end
            
            if nargin>0
                p=sr;
            end
            
            pr=p;
            
        end
        
    end
    
end