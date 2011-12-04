classdef FileCat < handle
    % FileCat takes care of all the messy I/O of the cat experiments.
    % The idea is that all your interfacing with the raw data is done
    % through this class.  The FelineFileFinder class stores an array of
    % FileCat objects.  To get a saved cat file, go:
    % F=FelineFileFinder; F.Start; C=F.GrabCat;
    %
    % Useful Methods (Loading Data)
    % C=FileCat; C.GrabCat;          	% Load the data for a cat.
    % C.Edit;                          	% Edit list of associated files
    % [bound condish]=C.loadTrialInfo 	% Load trial boundaries and associated conditions
    % [spikes id]=C.loadSpikeInfo     	% Get spikes, trial boundaries
    % [raw fS]=C.GetRaw;               	% Get Raw voltage data, samlping rate
    % [stim times]=C.StimGrab;        	% Grab Stimulus
    % [spikes id]=C.spikeWaveforms   	% Get spiking waveforms
    % [psth conds ids]=C.PSTH         	% Get psth (in cell array)
    %
    % Useful Methods: (Viewing Data)
    % C.View                          	% View voltage trace with spike/trial times overlayed
    % C.View_PSTH                     	% View a raster plot of spike times by trial
    % C.View_Spikes                   	% View the spike waveforms
    % C.summary                      	% text summary of FileCat Object
    %
    % To add a new file to the group:
    % 1) Add property (eg xxxxFile='';)
    % 2) Add the property to the URLfields list in StartGUI (see below)
    % 3) Add entry to "links" property (linking the property to the tag of the edit box)
    % 4) Optionally, edit the autoAdd method to make the files added automatically when you press it
    
   properties % All the visible ones
       
       cat='';      % eg 1208
       stage='';    % eg P4C1
       type='';     % eg whitenoise   *see "allowed types"
       ext='';      % eg 2  *usually leave blank
       
       root='';       
       spikeFile='';
       dataFile='';
       eegFile='';
       stimFile='';
       stimTimeFile='';
       voltageFile='';
       photoFile='';
       psthFile='';
       
       notes='';  % any additional info
       
   end
   
   properties (Hidden,Transient,AbortSet)
       % Static Properties
       
       allowedTypes={'', 'whitenoise','tuning','movies'}; 
       
       links={... % Linkings of properties to handle edit objects
           'cat'            'editCat';
           'stage'          'editStage';
           'ext'            'editExt';
           'root'           'editRoot';
           'spikeFile'      'editSpike';
           'dataFile'       'editData';
           'voltageFile'    'editVoltage';
           'eegFile'        'editEEG';
           'stimFile'       'editStim';
           'stimTimeFile'   'editStimTime'
           'photoFile'      'editPhoto';
           'psthFile'       'editPSTH';
           'notes'          'editNotes';
           }
       
        
        defaultroot='/projects/kevan/DataSylvia/MastersThesis';
       
        h;   % GUI handles

        % Determines whether, if a psth file exist, to load from it, or from
        % the spikeFile.  If set to false, psthFile is rendered impotent.
        loadfromPSTH=true;
              
   end
    
   methods % Data-Loading Methods
       %%
       
       function [stim edges]=StimGrab(A)
           % Outputs stim, a 3-d matrix (maybe make it a 1-D cell array of
           % 2-D matrices to save space on repreated presentations),
           % representing the stimulus.
           %
           % edges is the time vector of the stimulus transitions.  It
           % should be of length (size(stim,3)+1)
           
           F=load(A.stimFile);
           G=load(A.dataFile);
           
           
           switch A.type
               case 'whitenoise'
                   % Sylvia's function
                   stim=getStimulusFrames(F.stimuli);                   
                   
                   % Get times
                   start=G.data.channels.ch4.point1(1);
                   dur=F.stimuli.stimulusDuration/1000; % Convert to seconds
                   edges=start:dur:dur*size(stim,3)+start;
                                               
                     
               case 'movies'
                   
                   
                   
               case 'tuning'
                   
               otherwise 
                   error('Unknown stimulus type: "%s"',A.type);
                   
           end
           
           if length(edges)~=size(stim,3)+1
              error('Length of edge vector should be size(stim,3)+1)');
           end
           
       end
              
       function [bound condish]=loadTrialInfo(A)
           
           
           
           switch A.type
               
               
               
                case 'tuning'
                    G=load(A.dataFile);
                    if ~isfield(G,'data')
                       error 'Expected to find "data" in dataFile.  Didn''t!';
                    end
                    bound=G.data.channels.ch6.point1(1:2:end);
                    condish=G.data.channels.ch6.point2(1:2:end);
                case 'movies'
                    [~,~,bound]=photoDiode(A);
                    bound=bound(:);
                    condish=ones(size(bound)-1);
                    
                otherwise
                    disp (['Automatic calculation of bounds/' ...
                        'conditions not yet supported for movies ' ...
                        'or whitenouse.  This''ll change.'])
                    bound=[];
                    condish=1;
            end
           
           
       end
       
       function [spikes id]=loadSpikeInfo(A)
           
           % Load and Confirm
            F=load(A.spikeFile);
            
            if ~isfield(F,'cluster_class')
                error 'Expected to find "cluster_class" in spikeFile.  Didn''t!';
            end
            
                        
            % Get useful data from file
            spikes=F.cluster_class(:,2)/1000;
            id=F.cluster_class(:,1);
            
           
       end
       
       function stimuli=stimInfo(A,byTrial)
           % Load the stimulus structure by condition (byTrial=false) or by
           % Trial (byTrial=true).
           %
           % in the fist case, the stimulus vector length should be the
           % same as the condition vector length.
           
           if ~exist('byTrial','var'), byTrial=false; end
           
           F=load(A.stimFile);
           
           stimuli=F.stimuli;
           
           if ~byTrial
               % Load 
              [~,m]=unique([stimuli.Index]);
              stimuli=stimuli(m);
           end
           
           
       end
       
       function [spikes id]=spikeWaveforms(A)
           
           F=load(A.spikeFile);
           
           if isfield(F,'cluster_class')
               id=F.cluster_class(:,1);
               spikes=F.spikes;
           else
              error ('Expected to find "cluster_class" in spikeFile.  Didn''t');
           end
           
       end
      
       function [raw fS]=GetRaw(A)
           
           F=load(A.voltageFile);
           raw=F.ALL.channels.ch1.point1;
           fS=F.ALL.channels.ch1.actualSamplingRate;
           
       end
       
       function Edit(A)
           A.GetFiles(true);
           
       end
      
       function success=GetFiles(A,editit)
          if ~exist('editit','var'), editit=false; end
          success=false;
          
          A.startGUI(editit);
                    
          uiwait(A.h.figure1);
          
          if ~ishandle(A.h.figure1) % Window was closed/cancel was pressed
              return;
          end

          % Put info in structure
          for i=1:size(A.links,1)
              A.(A.links{i,1})=get(A.h.(A.links{i,2}), 'string');
          end
          sss=get(A.h.popType,'string');
          A.type=sss{get(A.h.popType,'value')};

          
          A.initialList(true); % Save this list for next time
          success=true;
          close(A.h.figure1);
                   
           
       end
           
       function name=catName(A)
           
           name=['cat' A.cat '~' A.stage '~' A.ext];
           
       end
       
       function classitup(A)
           % Just renews the static features links and allowed types when
           % the list is changed.
           
           B=eval(class(A));
           
           A.links=B.links;
           A.allowedTypes=B.allowedTypes;
           A.loadfromPSTH=B.loadfromPSTH;
       end
      
       function [psth conds ids]=PSTH(A)
           % Disclaimer: id's may be incorrect IF a cell has been removed,
           % and psth is loaded directly from psthFile.
           % Because occasionally a set of spikes will be cleared.
           
           if A.loadfromPSTH && ~isempty(A.psthFile)
              fprintf 'Loading from psthFile...'
              % Already sorted by trials
              F=load(A.psthFile);
              psth=cellfun(@(x)x/1000,F.psths(:,:),'uniformoutput',false);
              
              % This may seem silly.. but its here because silvia's
              % pre-existing psth's have cell 0 removed, and the generated
              % ones don't.
              psth=[cell(1,size(psth,2)); psth];
              
              ids=0:size(psth,1)-1;
%               ids=['0' 'A': char('A'+size(psth,2)-1)];
              conds=repmat(1:size(F.psths,2),[1 size(F.psths,3)]);
           else
               fprintf 'Calculating PSTH from spikeFile...'
               [bound conds]=A.loadTrialInfo;
               [spikes id]=A.loadSpikeInfo;
               [psth ids]=SplitSpikes(spikes,id,bound);
           end
           disp Done
                      
       end
       
       function [photo fS splits]=photoDiode(A)
           
           F=load(A.photoFile);
           photo=F.ALL.channels.ch2.point1;
           fS=F.ALL.channels.ch2.actualSamplingRate;
           
           if nargout>2 % Find splits
               
               splits=TrialParse(photo);
               
               splits=(splits-1)/fS;
               
           end
           
           
           
       end
       
      
       
   end
   
   methods % Viewing Methods
       %%
       function View(A)
          
           hW=waitbar(0.5,'Patience-lots of data here.  It''ll take a while to load.');
           [spikes id]=A.loadSpikeInfo;
           bound=A.loadTrialInfo;
           
           [raw fS]=GetRaw(A);
           time=0:1/fS:(length(raw)-1)/fS;
           
           colordef black;
           figure('toolbar','figure')
           iplot(time,raw,'color',[.5 .5 .5]);
           hold on;
           title(['cat' A.cat '~' A.stage '~' A.type A.ext]);
           
           
           if isvector(spikes)
               u=unique(id);
               ns=nan(length(u),1);
               hS=nan(1,length(u));
               for i=1:length(u)
                  ix=id==u(i);
                  hS(i)=addlines(spikes(ix),'visible','off');% set(hh,'); 
                  ns(i)=nnz(ix);
               end
               xlabel time(s);
               hT=addlines(bound,'color','w','LineWidth',2,'visible','off');

               
           elseif iscell(spikes) % This shouldn't happen anymore and could probably be removed
               v=axis;
              text(v(2),v(4),'Spikes already sorted as PSTH','HorizontalAlignment','right');
               
           end
           
           
           
                     
           if exist(A.photoFile,'file')
               
               [photo fSp]=A.photoDiode;
               offset=(max(photo(ceil(length(photo)*rand(1,1000))))...
                       -min(raw(ceil(length(raw)*rand(1,1000)))))*1.2;
               
               timeP=0:1/fSp:(length(photo)-1)/fSp;
               iplot(timeP,photo-offset,'color',[.5 .5 1]);
               legend([A.cellLegend(u,ns);'Trials';'photoDiode';'Voltage']);
           else
               legend([A.cellLegend(u,ns);'Trials';'Voltage']);
           end
                      
           set(gca,'children',circshift(get(gca,'children'),[1,0]));
           
           
           
           function linetog(s,handle)
               if get(s,'value');
                  arrayfun(@(x)set(x,'visible','on'),handle);
               else
                  arrayfun(@(x)set(x,'visible','off'),handle);
               end
           end
                      
           uicontrol('style','checkbox','string','Show Spikes',...
               'callback',@(s,e)linetog(s,hS),'value',false,'position',[0 2 100 13]);
           uicontrol('style','checkbox','string','Show Trials',...
               'callback',@(s,e)linetog(s,hT),'value',false,'position',[0 16 100 13]);
           
           delete(hW);
               
       end
       
       function View_PSTH(A)
           
           % Load PSTH (cell array)
           [psth,~,ids]=A.PSTH;
           
           % Set up plot (vertical offsets, etc)
           colordef black;
           figure;
           trialoffsets=1:size(psth,2);
           trialjump=trialoffsets(end)*1.1;
           celloffsets=ceil(trialjump*(0:size(psth,1)-1));
           celladdcell=cell(size(psth(:,:)));
           for i=1:size(psth,1), celladdcell(i,:)={celloffsets(i)}; end
           trialaddcell=cell(size(psth(:,:)));
           for i=1:size(psth,2), trialaddcell(:,i)={trialoffsets(i)}; end
           temp=cellfun(@(x,c,t)zeros(size(x))+c+t,psth,celladdcell,trialaddcell,'uniformoutput',false);
                    
           % Plot Spikes
           hh=nan(1,size(psth,1));
           hold all;
           cols=lines(size(psth,1));
           ns=nan(1,size(psth,1));
           for i=1:size(psth,1);
               mat=cell2mat(psth(i,:)');
               ns(i)=numel(mat);
               hh(i)=scatter(mat,cell2mat(temp(i,:)'),'+','markeredgecolor',cols(i,:));
           end           
           
           % Plot trial-lines
           for i=1:size(psth,1);
               addlines(trialoffsets+celloffsets(i),'h','color',[0.3 .3 .3]);
           end           
           set(gca,'children',flipud(get(gca,'children')));           
           set(gca,'ydir','reverse');
                     
           % Title and legend
           title(A.catName);
           legend(hh,A.cellLegend(ids,ns));
           
       end
       
       function View_Spikes(A)
           % Plot of all the spike waveforms
           
           % Will plot all spikes as a single handle (as this makes it way
           % faster then having like a billion handles)
           [spikes id]=A.spikeWaveforms;
           spacing=2.5*max(std(spikes,[],2),[],1);
           spikes=[spikes nan(size(spikes,1),1)];
           times=repmat(1:size(spikes,2),size(spikes,1),1);
           u=unique(id);
           
           
           
           colordef black;
           figure;
           hold all;
           ns=nan(1,length(u));
           for i=1:length(u)
              ix=find(id==u(i));
              ns(i)=numel(ix);
              t=times(ix,:)';
              s=spikes(ix,:)'-i*spacing;
              plot(t(:),s(:));
           end
           
           title(A.catName);
           
           legend(A.cellLegend(u,ns));
       end
              
       function Experience(A)
           
          A.View;
          title 'Click plot to experience the data';
          hF=gcf;
          set(gca,'ButtonDownFcn',@(e,s)uiresume(hF));
          
          [raw fS]=A.GetRaw;
          playa=audioplayer(raw,fS);
                    
          
          
          time=1;
          
          hL=addlines(0,'r');
          while true
              
              uiwait(hF);
              if ~ishandle(hF), return; end
              
              switch gco
                  case gca
                      
                      if isplaying(playa)
                          stop(playa);
                      else
                          p=get(gca,'CurrentPoint');
                          ix=quickfind(p(1),time);
                          playa.play(round(ix));
                          set(hL,'xdata',repmat(p(1),size(get(hL,'xdata'))));
                      end
                                        
              end
              
              
          end
           
           
       end
       
       function txtsum=summary(A)
           
           function fname=shortname(file)
              [~,file exten]=fileparts(file);
              fname=['.../' file exten];
           end
           
           function txxt=listpropset(props,isafile)
               txxt='';
               for i=1:length(props)
                   if ~isafile, val=A.(props{i});
                   else val=shortname(A.(props{i}));
                   end
                   txxt=[txxt sprintf('%s: %s\n',props{i},val)]; %#ok<AGROW>
               end
               txxt=[txxt sprintf('\n')];
                                  
           end
           
           % Make String to display (yeah yeah innefficient whatever)
           txt=listpropset({'cat','stage','ext','type'},false);           
           P=properties(A);
           Pfiles=P(cellfun(@(x)~isempty(x),strfind(P,'File')));           
           txt=[txt listpropset(Pfiles,true)];           
           txt=[txt listpropset({'notes'},false)];
           
           if nargout>0
               txtsum=txt;
           else
               disp(txt);
           end
           
       end
       
   end
      
   methods % GUI Methods
       %%
       
       function startGUI(A,editit)
           % Start the GUI and link up all the gui controls
          if ~exist('editit','var'), editit=false; end
          
          A.h =exploadGUI7;
          
          % Add pop-list functionality
          A.addURLfields({'spikeFile','dataFile','voltageFile','eegFile',...
              'stimFile','stimTimeFile','photoFile','psthFile'});
                    
          % Setup "type" list
          set(A.h.popType,'string',A.allowedTypes);
          
          % Put-up previous saved list if same root as last time.
          A.initialList;
          if editit % Add previous assignments
              for i=1:size(A.links,1)
                  set(A.h.(A.links{i,2}), 'string',A.(A.links{i,1}));
              end
              v=find(strcmpi(A.type,A.allowedTypes));
              if isempty(v),v=1; end
              set(A.h.popType,'value',v);
              
              A.filterlist;
          end
                    
          % Set search functions
          if isdir(A.defaultroot)
              set(A.h.editRoot,     'string', A.defaultroot);
          end
          
          set(A.h.pushSearch,       'callback',@(e,s)A.searchfunction);
          
          % Set Filter/Auto-Add Functions
          set(A.h.pushFilter,       'callback',@(e,s)A.filterlist);
          set(A.h.pushAuto,         'callback',@(e,s)A.autoAdd);
          
          % Add Go/Cancel Functionality
          set(A.h.pushGO,           'callback',@(e,s)uiresume(A.h.figure1));
          set(A.h.pushCancel,       'callback',@(e,s)delete(A.h.figure1));
       end
       
       function searchfunction(A)

            rooot=get(A.h.editRoot,'string');
            if ~isdir(rooot);
               w=errordlg(sprintf('"%s"\n is not a valid directory!',rooot));
               uiwait(w);
               return;
            end

            % Recursive search
            hwb=waitbar(0,'Searching Directory...');
            [~, urls]=Crawler(rooot);
            delete(hwb);

            % Load into list
            A.putupList(urls,rooot);
       end
       
       function initialList(A,setit)
           % This just saves time by saving the list in a persistent
           % variable, sot that repeated calls bring up the list from last
           % time. 
           % setit: false=load last list, true=save this one
           
           persistent rooot urls
           
           if nargin<2, setit=false; end
           
           if setit % Set Mode
               rooot=A.getlistData('root');
               urls=A.getlistData('urls');
           elseif isempty(A.root)||strcmp(rooot,A.root) % Put old results up there
               if ~isempty(rooot) && ~isempty(urls)
                   try 
                       set(A.h.editRoot,'string',rooot);
                       A.putupList(urls,rooot);
                   catch ME % Just so you don't get peristent errors from somehow mis-set persistents
                      disp(ME.getreport)
                      rooot=[];
                      urls=[];
                   end
               end
               
           end
                      
       end
              
       function getDir(A)
           
            persistent d
            if isdir(d), cd(d); end

            di=uigetdir;
            if di~=0
                d=di;
                set(A.h.editRoot,'string',d);
            end
           
       end
       
       function filterlist(A)
           
            urls=A.getlistData('urls');
            if isempty(urls)
                A.searchfunction;
                urls=A.getlistData('urls');
            end
            

            rooot=A.getlistData('root');

            norig=length(urls);

            % Cut off the root
            urls=cellfun(@(x)x(length(rooot)+1:end),urls,'uniformoutput',false);

            % Filter for cat...
            urls=A.filters(urls,get(A.h.editCat,'string'));

            % Filter for the stage (because it doesn't feel right to call it penetration)
            urls=A.filters(urls,get(A.h.editStage,'string'));

            % Filter for Experiment Type
            urls=A.filters(urls,get(A.h.editExt,'string'));

            % Shorten List String
            set(A.h.listSearch,'String',urls);
            set(A.h.textSearch,'String',sprintf('Displaying %g filtered out of %g total results',length(urls),norig));

        end

       function F=getlistData(A,field)

            if isempty(get(A.h.listSearch,'UserData'))
                F=[];
            else
                S=get(A.h.listSearch,'UserData');

                F=S.(field);

            end
       end

       function putupList(A,urls,rooot)
           
           A.setlistData('root',rooot);
           A.setlistData('urls',urls);
           set(A.h.listSearch,'string',urls);
           set(A.h.textSearch,'string',sprintf('Found %g mat files in root',length(urls)));

           
       end
       
       function setlistData(A,field,value)

            if ~isempty(get(A.h.listSearch,'UserData'))
                F=get(A.h.listSearch,'UserData');
            end

            F.(field)=value;   

            set(A.h.listSearch,'UserData',F);

        end

       function listpush(A,dest,number)
            % Number is optional, otherwise the selected item is pushed
            if ~exist('number','var')
                number=get(A.h.listSearch,'value');
            elseif isempty(number)
                set(dest,'string',''); return;
            elseif (isnan(number))
                set(dest,'string','n/a'); return;
            end
           
            list=get(A.h.listSearch,'string');
            if ~isempty(list)
                rooot=A.getlistData('root');
                fullurl=[rooot list{number}];
                set(dest,'string',fullurl);
            end

       end
              
       function autoAdd(A)
           % Automatically add items to list based on filters
           
           
           
           if isempty(A.h.editCat) || isempty(A.h.editStage);
               hw=warndlg('First fill in a Cat and a Stage!');
               uiwait(hw);
               return;
           end
           
           A.filterlist;
           
           function filler=scanfor(list,token)
               r=regexpi(list,token);
               matches=cellfun(@(x)~isempty(x),r);
               if nnz(matches)==1
                  filler=find(matches,1);
               else
                   filler='';
               end
               
           end
           
           
           
           % For more compact reference
           kat=get(A.h.editCat,'string');
           id=get(A.h.editExt,'string'); % like "P4C1"
           stg=get(A.h.editStage,'string'); % like "tuning2"
           tok=[stg '_' id]; % like "P4C1_tuning2" 
           list=get(A.h.listSearch,'string');
               
           
           % For each file, if a unique file is found it'ing it, add it.
           A.listpush(A.h.editSpike,scanfor(list,[filesep 'times_' tok '_Voltage1.mat']));
           A.listpush(A.h.editData,scanfor(list,[filesep tok '.mat']));
           A.listpush(A.h.editVoltage,scanfor(list,[filesep tok '_Voltage1.mat']));
           A.listpush(A.h.editEEG,scanfor(list,[filesep tok '_EEG_1.mat']));
           A.listpush(A.h.editPhoto,scanfor(list,[filesep tok '_Photodio1.mat']));
           A.listpush(A.h.editPSTH,scanfor(list,['(movies' filesep 'psth_)*' stg '.mat']));
           A.listpush(A.h.editStim,scanfor(list,['stimuli' filesep 'cat' kat '_' tok '.mat']));
           
           % *psth one is a little complicated, cause they only exist for movies now
           
           % Detect the type
           detect=@(toks) any(~cellfun(@isempty,regexpi(get(A.h.editExt,'string'),toks)));
           setval=@(str) set(A.h.popType,'value',find(strcmp(str,get(A.h.popType,'string')),1));
           if detect ({'whitenoise','inversetime'})
               setval('whitenoise')
               A.listpush(A.h.editStimTime,nan);
           elseif detect({'tuning'})
               setval('tuning')
           elseif detect({'movies'})
               setval('movies')
               
               
           end
           
       end
       
       function addURLfields(A,props)
           
           [yep,ix]=ismember(props,A.links(:,1));
           
           if ~all(yep)
              error(['You tried to add a URL-box for property "%s", but '...
                  'it''s not listed  in "Links" so we don''t know what GUI '...
                  'component to link it to.  See property "Links" and add it'],...
                  props(find(yep,1)));
           end
           
           % 
           genericHandles=[A.h.pushXXXAdd A.h.editXXX A.h.pushXXXFind];
           uihandles=cell2mat(struct2cell(A.h)); uihandles=uihandles(2:end);
           
           ypos=@(y)arrayfun(@(x)get(x,'position')*[0 1 0 0]',y);
           offset=2.2*(length(ix):-1:1);
           tomove=uihandles(ypos(uihandles) >= min(ypos(genericHandles)));  
           
           
           % Expand figure
           set(0,'units','characters');set(A.h.figure1,'units','characters');
           fpo=get(A.h.figure1,'position'); spo=get(0,'ScreenSize');
           fpo(4)=fpo(4)+offset(1);
           if fpo(2)+fpo(4)>spo(4),fpo(2)=spo(4)-fpo(4); end
           set(A.h.figure1,'position',fpo);
                      
           % Add the files
           arrayfun(@(ind,off)A.addURLfield(A.links{ind,1},A.links{ind,2},off),...
               ix,offset+ypos(genericHandles(1)));
           
           % Move shit to make room
           arrayfun(@(x)set(x,'position',get(x,'position')+[0 offset(1) 0 0]),tomove);
           
       end
       
       function addURLfield(A,propname,fieldname,offset)
           % Adds a "load file" field with all functionality.
           % Important convention: the name of the associated 
                                
           % Copy uicontrols, add their functionality
           parent=get(A.h.pushXXXAdd,'parent');
           hAdd=copyobj(A.h.pushXXXAdd,parent);
           hEdit=copyobj(A.h.editXXX,parent);
           hFind=copyobj(A.h.pushXXXFind,parent);
           set(hAdd,  'callback',@(e,s)A.listpush(hEdit),'string',[propname '>>']);
           set(hFind, 'callback',@(e,s)A.manualsearch(hEdit, ['Get ' propname]));
           
           % Move to right location.
           moveoff=@(x)set(x,'position',get(x,'position').*[1 0 1 1]+[0 offset 0 0]);
           moveoff(hAdd);
           moveoff(hEdit);
           moveoff(hFind);
                          
           % Store the handles
           A.h.(['add_'  propname])=hAdd;
           A.h.(fieldname)=hEdit;
           A.h.(['find_' propname])=hFind;
       end
       
       
   end
      
   methods (Static)
       %%
       function labels=cellLegend(ids,counts)
           % Just Returns cell labels where ids is a vector of cell ids
           
           
           cf=@(x)cellfun(@num2str,mat2cell(x(:),ones(numel(x),1)),'uniformoutput',false);
           
           labels=strcat('cell-',cf(ids));
           
           if exist('counts','var')
               
              labels=strcat(labels,': (', cf(counts), ' spikes)');
           end
           
       end
       
       function list=filters(list,str)
            if ~isempty(str)
                token=str;
                ix=cellfun(@(x)~isempty(strfind(x,token)),list);
                list=list(ix);
            end
       end
       
       function manualsearch(dest,inst)
            
            if ~exist('inst','var'), inst=''; end
            
            persistent loc;
            if ~isdir(loc), loc=cd; end
            cd (loc);

            [file nloc]=uigetfile('*.mat',inst);
            if file
                loc=nloc;
                set(dest,'string',[loc file]);
                cd (loc);
            end            
       end       
       
   end
        
end




