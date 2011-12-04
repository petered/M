classdef FileCat < handle
% =========================================================================
% FileCat (<a href="matlab:edit('FileCat')">Edit</a>)
%
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
%     
% =========================================================================
   properties % All the visible ones
       
       cat='';      % eg 1208
       stage='';    % eg P4C1
       ext='';      % eg tuning2 
       
       type='';     % eg whitenoise   *see "allowed types"
       
       root='';       
       spikeFile='';
       dataFile='';
       eegFile='';
       stimFile='';
       stimTimeFile='';
       voltageFile='';
       photoFile='';
       psthFile='';
       
       badCells=0; % Boolean array of 'bad' cells, as defined by experimentor.
       
       notes='';  % any additional info
       
   end
   
   properties (Hidden,Transient,AbortSet)
       % Static Properties
       
       allowedTypes={'', 'whitenoise','tuning','movies'}; 
       
       tuningChop=true;
       
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
       
%         h;   % GUI handles

        % Determines whether, if a psth file exist, to load from it, or from
        % the spikeFile.  If set to false, psthFile is rendered impotent.
        loadfromPSTH=true;
              
   end
    
   methods % Data-Loading Methods
       %%
       
       function [stim edges map]=StimGrab(A)
           % Outputs stim, a 3-d matrix (maybe make it a 1-D cell array of
           % 2-D matrices to save space on repreated presentations),
           % representing the stimulus.
           %
           % edges is the time vector of the stimulus transitions.  It
           % should be of length (size(stim,3)+1)
           %            
           % map is used when stim is output as a cell array.  Since
           % stimuli are repeated, map is a vector containing the indesx of
           % the stimulus played on each trial.  stim(map) will produce a
           % cell array of stimuli the length of the number of trials.
           
                      
           switch A.type
               case 'whitenoise'
                   
                   F=load(A.stimFile);
                   G=load(A.dataFile);
                   
                   % Sylvia's function
                   stim=getStimulusFrames(F.stimuli);                   
                   
                   % Get times
                   start=G.data.channels.ch4.point1(1);
                   dur=F.stimuli.stimulusDuration/1000; % Convert to seconds
                   edges=start:dur:dur*size(stim,3)+start;
                               
                   map=[]; % Irrelevant so far.
                     
                   
                   if length(edges)~=size(stim,3)+1
                      error('Length of edge vector should be size(stim,3)+1)');
                   end
                   
               case 'movies'
                   
%                    stim=F.movie;
%                    nframes=size(stim,3);
%                     nframes=500;
                   
                   % Hardcoded for now... will need to change
%                  
                   movs=1:18;
                   stim=A.grabmovies(movs);
                   
                   nframes=cellfun(@(x)size(x,3),stim(:),'uniformoutput',false);
                   
                   
                    
                   % Find edges from photodiode signal
                   [~,~,ev, ix]=A.photoDiode;                 
                   
                   map=mod(0:length(ix)-1,length(stim))+1;
                   
                   % NOTE: below command has a teeny tiny problem: The
                   % photodiode signal looks quite funny - sometimes frames
                   % are "missed".  If the first or last frame is "missed",
                   % then the frame times will be a little off what they
                   % should be.  
                   edges=cellfun(@(c,n)linspace(c(1),c(end)+min(diff(c)),n+1), ix(:), nframes(map),'uniformoutput',false);
                                      
               case 'tuning'
                   
                   error('Stim-Grab not supported for tuning yet');
                   
               otherwise 
                   error('Unknown stimulus type: "%s"',A.type);
                                    
           end
           
           
       end
              
       function [bound condish]=loadTrialInfo(A)
                     
           switch A.type
                              
                case 'tuning'
                    G=load(A.dataFile);
                    if ~isfield(G,'data')
                       error 'Expected to find "data" in dataFile.  Didn''t!';
                    end
                    if A.tuningChop
                        bound=[G.data.channels.ch6.point1(1:2:end-1);G.data.channels.ch6.point1(2:2:end)];
                    else
                        bound=G.data.channels.ch6.point1(1:2:end); % Includes blank in trial
                    end
                    
                    condish=G.data.channels.ch6.point2(1:2:end);
                case 'movies'
                    if ~isempty(A.photoFile)
                        [~,~,bound]=A.photoDiode;
                        bound=bound(:);
                        condish=ones(size(bound)-1);
                    else
                        disp 'NO PHOTO-DIODE FILE FOUND.  RETURNING EMPTY BOUNDS';
                        bound=[];
                        condish=[];
                    end
                    
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
          
          h=A.startGUI(editit);
                    
          uiwait(h.figure1);
          
          if ~ishandle(h.figure1) % Window was closed/cancel was pressed
              return;
          end

          % Put info in structure
          for i=1:size(A.links,1)
              A.(A.links{i,1})=get(h.(A.links{i,2}), 'string');
          end
          sss=get(h.popType,'string');
          A.type=sss{get(h.popType,'value')};

          
          h.SaveMe(); % Save this list for next time
          success=true;
          close(h.figure1);
                   
           
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
      
       function [psth conds ids]=PSTH(A,filterBaddies)
           % Disclaimer: id's may be incorrect IF a cell has been removed,
           % and psth is loaded directly from psthFile.
           % Because occasionally a set of spikes will be cleared.
           
           if ~exist('filterBaddies','var'), filterBaddies=false; end
                      
           if A.loadfromPSTH && ~isempty(A.psthFile)
              fprintf 'Loading from psthFile...'
              % Already sorted by trials
              F=load(A.psthFile);
              psth=cellfun(@(x)x/1000,F.psths(:,:),'uniformoutput',false);
              
              % This may seem silly.. but its here because silvia's
              % pre-existing psth's have cell 0 removed, and the generated
              % ones don't.
              psth=[cell(1,size(psth,2)); psth];
              
              SF=load(A.spikeFile);
              ids=unique(SF.cluster_class(:,1));
%               ids=['0' 'A': char('A'+size(psth,2)-1)];
              conds=repmat(1:size(F.psths,2),[1 size(F.psths,3)]);
           else
               fprintf 'Calculating PSTH from spikeFile...'
               [bound conds]=A.loadTrialInfo;
               [spikes id]=A.loadSpikeInfo;
               [psth ids]=SplitSpikes(spikes,id,bound);
           end
           disp Done
           
           if filterBaddies
              ix=~ismember(ids,A.badCells);
              ids=ids(ix);
              psth=psth(ix,:);              
           end
           
           % Safety Check
           if ~all(cellfun(@issorted,psth(:)))
               error('Spikes in the psth aren''t sorted in time.  THIS IS A PROBLEM!');
           end
           
                      
       end
       
       function [photo fS splits ticks]=photoDiode(A)
           
           F=load(A.photoFile);
           photo=F.ALL.channels.ch2.point1;
           fS=F.ALL.channels.ch2.actualSamplingRate;
%            
%            function showres
%                iplot(linspace(0,(length(photo)-1)/fS,length(photo)),photo);
%                for i=1:length(ticks), addlines(ticks{i}); end
%            end
           
           
           if nargout>2 % Find splits
           
               disp('Scanning PhotoDiode Signal...');
               [splits ticks]=TrialParse(photo);
               
               
               
               fprintf('Found %g trials.\n',size(splits,1));
               
               
               
               
               
               % Convert to regular time units.
               ix2time=@(ix)(ix-1)/fS;
               splits=ix2time(splits);
               ticks=cellfun(ix2time,ticks,'uniformoutput',false);
              
               % Run the following to check if the edges make sense:
%                iplot(linspace(0,(length(photo)-1)/fS,length(photo)),photo);
%                for i=1:length(ticks), addlines(ticks{i}); end
               
           end
           
           
           
       end
       
       function mov=grabmovies(A,numbers)
            % Returns a cell array of 3-D matrices representing movies of 
            % the given numbers.

            assert(~isempty(A.stimFile),'No stimFile has been associated with this experiment.  Run FelineFileFinder to fix this');
            
            movloc=A.stimFile;

            if ~exist('numbers','var'),isempty(numbers),
               % guess
               numbers=1:18;
            end

            movname=@(i)sprintf('%s%smovie%02g.mat',movloc,filesep,i);
            [mov nframes]=deal(cell(1,length(numbers)));
            fprintf('Loading Movie..');
            for i=1:length(numbers)
               fprintf('%g..',numbers(i));
               m=load(movname(numbers(i)));
               % Note: movie resulution unneccesairly doubled for
               % some odd reason, and double-precision is a waste of space.
               mov{i}=single(m.movie(1:2:end,1:2:end,:)); % No need for double here.
               nframes{i}=size(mov{i},3);
            end
            disp('Done!');

       end
       
   end
   
   methods % Viewing Methods
       %%
       function View(A)
           % Plot the raw-data.  Note that this includes spikes from 
           % "cell 0", which is generally thrown out before loading the
           % spikes into the object that does the processing.
           
           hW=waitbar(0.5,'Patience-lots of data here.  It''ll take a while to load.');
           [spikes id]=A.loadSpikeInfo;
           bound=A.loadTrialInfo;
           
           [raw fS]=GetRaw(A);
           time=0:1/fS:(length(raw)-1)/fS;
           
           colordef black;
           figure('toolbar','figure')
           iplot(time,raw,'color',[.5 .5 .5]);
           hold on;
           A.catName;
           
           
           % Add the spikes signal;
           if isvector(spikes)
               
               % Add neuron spiking lines
               u=unique(id);
               ns=nan(length(u),1);
               hS=nan(1,length(u));
               for i=1:length(u)
                  ix=id==u(i);
                  hS(i)=addlines(spikes(ix),'visible','off');% set(hh,'); 
                  ns(i)=nnz(ix);
               end
               xlabel time(s);
               
               % Trial Lines (white)
               hT=addlines(bound,'color','w','LineWidth',2,'visible','off');

               
           elseif iscell(spikes) % This shouldn't happen anymore and could probably be removed
              error('The FileCat hates you.');
%               v=axis;
%               text(v(2),v(4),'Spikes already sorted as PSTH','HorizontalAlignment','right');
               
           end
           
           % Put raw signal on top.
           set(gca,'children',circshift(get(gca,'children'),[1,0]));
           
           % Add the photodiode signal
           if exist(A.photoFile,'file')
               [photo fSp splits ticks]=A.photoDiode;
               offset=(max(photo(ceil(length(photo)*rand(1,1000))))...
                       -min(raw(ceil(length(raw)*rand(1,1000)))))*1.2;
               timeP=0:1/fSp:(length(photo)-1)/fSp;
               iplot(timeP,photo-offset,'color',[.5 .5 1]);
               legend([A.cellLegend(u,ns);'Trials';'photoDiode';'Voltage']);
               
               % Add all the crazy tick marks
               hold on;
               hTick=nan(1,length(ticks)+1);
               hTick(1)=addlines(splits(:),'linestyle',':','linewidth',2,'visible','off');
               for i=1:length(ticks)
                   hTick(i+1)=addlines(ticks{i},'visible','off');% set(hh,'); 
               end
               
           else
               legend([A.cellLegend(u,ns);'Trials';'Voltage']);
           end
           
           
           
           % Function to turn on/off lines.
           function linetog(s,handle)
               if get(s,'value');
                  arrayfun(@(x)set(x,'visible','on'),handle);
               else
                  arrayfun(@(x)set(x,'visible','off'),handle);
               end
           end
           
           % Add controls
           uicontrol('style','checkbox','string','Show Spikes',...
               'callback',@(s,e)linetog(s,hS),'value',false,'position',[0 2 100 13]);
           uicontrol('style','checkbox','string','Show Trials',...
               'callback',@(s,e)linetog(s,hT),'value',false,'position',[0 16 100 13]);
           if exist(A.photoFile,'file')
           uicontrol('style','checkbox','string','Show Photo-Diode Parsing',...
               'callback',@(s,e)linetog(s,hTick),'value',false,'position',[0 30 100 13]);
           end
           
           
           
           delete(hW);
               
           
           Viewer.addHelpButton;
           
       end
       
       function View_PSTH(A)
           
           S=SpikeBanhoff;
           
           oldstate=A.tuningChop;
           A.tuningChop=false;
           S.GrabCat(A,false); % Take the cat without removing cell 0;
           A.tuningChop=oldstate;
           
           S.Plot_Raster;
           
%            % Load PSTH (cell array)
%            [psth,~,ids]=A.PSTH;
%            
%            % Set up plot (vertical offsets, etc)
%            colordef black;
%            figure;
%            trialoffsets=1:size(psth,2);
%            trialjump=trialoffsets(end)*1.1;
%            celloffsets=ceil(trialjump*(0:size(psth,1)-1));
%            celladdcell=cell(size(psth(:,:)));
%            for i=1:size(psth,1), celladdcell(i,:)={celloffsets(i)}; end
%            trialaddcell=cell(size(psth(:,:)));
%            for i=1:size(psth,2), trialaddcell(:,i)={trialoffsets(i)}; end
%            temp=cellfun(@(x,c,t)zeros(size(x))+c+t,psth,celladdcell,trialaddcell,'uniformoutput',false);
%                     
%            % Plot Spikes
%            hh=nan(1,size(psth,1));
%            hold all;
%            cols=lines(size(psth,1));
%            ns=nan(1,size(psth,1));
%            for i=1:size(psth,1);
%                mat=cell2mat(psth(i,:)');
%                ns(i)=numel(mat);
%                hh(i)=scatter(mat,cell2mat(temp(i,:)'),'+','markeredgecolor',cols(i,:));
%            end           
%            
%            % Plot trial-lines
%            for i=1:size(psth,1);
%                addlines(trialoffsets+celloffsets(i),'h','color',[0.3 .3 .3]);
%            end           
%            set(gca,'children',flipud(get(gca,'children')));           
%            set(gca,'ydir','reverse');
%                      
%            % Title and legend
%            title(A.catName);
%            legend(hh,A.cellLegend(ids,ns));
           
       end
       
       function View_Spikes(A)
           % Raw Data Spike Waveforms
           % Plot of all the spike waveforms.  These were used in
           % spike-clasification.
           
           
           
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
           
           Viewer.addHelpButton;
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
       
       function txtsum=summary(A,shorten)
           
           if ~exist('shorten','var'), shorten=true; end
           
           function fname=shortname(file)
              [~,file exten]=fileparts(file);
              fname=['.../' file exten];
           end
           
           function txxt=listpropset(props,isafile)
               txxt='';
               for i=1:length(props)
                   if isafile && shorten, val=shortname(A.(props{i}));
                   else val=A.(props{i});
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
           txt=[txt sprintf('\nBad Cells: %s',num2str(A.badCells(:)'))];
           
           if nargout>0
               txtsum=txt;
           else
               disp(txt);
           end
           
       end
       
       function Edit_Comments(A)
           
           res=inputdlg(A.catName,'Notes',5,{A.notes});
           if isempty(res), return; end
           
           A.notes=res{1};
           
       end
       
       function View_Stimulus(A)
           
           if ~ismember(A.type,{'movies','tuning'})
               hE=errordlg(['This function isn''t yet supported for ' A.type ' stumuli']);
               uiwait(hE);
               return;
           end
           
           
           [stim, edges, map]=A.StimGrab;
           
                      
           
           if isnumeric(stim)
               
               stim=squeeze(stim);
               switch ndim(stim)
                   case 1
                       figure;
                       plot(stim);
                       
                   case 2
                       figure;
                       imagesc(edges(1:end-1),[],stim);
                       colormap gray;
                       
                   case 3
                       M=MovieTime(stim,edges(1:end-1));   
                       M.play;
                       
                   otherwise
                       
                       
               end
               
                              
           elseif iscell(stim)
               
               M=MovieTime(stim(map),edges);
               M.play;
               
           end
           
           
           
           
           
       end
       
       function Select_Bad_Cells(A)
           % Opens a select Dialog to let you choose the bad cells.  
           
           [~,ids]=A.loadSpikeInfo;
           
           ids=unique(ids);
           
           cells=strcat('Cell ',arrayfun(@num2str,ids,'uniformoutput',false));
           
           init=find(ismember(ids,A.badCells));
           
           [sel ok]=listdlg('ListString',cells,'InitialValue',init);
           
           if ~ok, return; end
           
           A.badCells=ids(sel);
           
       end
       
   end
      
   methods % GUI Methods
       %%
             
       function h=startGUI(A,editit)
           % h is a structure allowing you to access all handles in the GUI
           % object, as well as the function SaveMe, which save the current
           % root/search-list so that it's automatically brought back up the next
           % time it's loaded.
          
           % Start the GUI and link up all the gui controls
          if ~exist('editit','var'), editit=false; end
          
          h =exploadGUI7;
          
          % Add pop-list functionality
          addURLfields({'spikeFile','dataFile','voltageFile','eegFile',...
              'stimFile','stimTimeFile','photoFile','psthFile'});
                    
          % Setup "type" list
          set(h.popType,'string',A.allowedTypes);
          
          % Put-up previous saved list if same root as last time.
          initialList;
          if editit % Add previous assignments
              for i=1:size(A.links,1)
                  set(h.(A.links{i,2}), 'string',A.(A.links{i,1}));
              end
              v=find(strcmpi(A.type,A.allowedTypes));
              if isempty(v),v=1; end
              set(h.popType,'value',v);
              
              filterlist;
          end
                    
          % Set search functions
          if isdir(A.defaultroot)
              set(h.editRoot,     'string', A.defaultroot);
          end
          
          set(h.pushSearch,       'callback',@(e,s)searchfunction);
          
          % Set Filter/Auto-Add Functions
          set(h.pushFilter,       'callback',@(e,s)filterlist);
          set(h.pushAuto,         'callback',@(e,s)autoAdd);
          
          % Add Go/Cancel Functionality
          set(h.pushGO,           'callback',@(e,s)uiresume(h.figure1));
          set(h.pushCancel,       'callback',@(e,s)delete(h.figure1));

          % Add saving functionality
          h.SaveMe=@()initialList(true);

           function searchfunction()

                rooot=get(h.editRoot,'string');
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
                putupList(urls,rooot);
           end

           function initialList(setit)
               % This just saves time by saving the list in a persistent
               % variable, sot that repeated calls bring up the list from last
               % time. 
               % setit: false=load last list, true=save this one
                persistent rooot urls


               if nargin<1, setit=false; end

               roooot=getlistData('root');
               urlls=getlistData('urls');
               
               if setit % Set Mode
                   rooot=roooot;
                   urls=urlls;
               elseif isempty(roooot)||strcmp(rooot,roooot) % Put old results up there
                   if ~isempty(rooot) && ~isempty(urls)
                       try 
                           set(h.editRoot,'string',rooot);
                           putupList(urls,rooot);
                       catch ME % Just so you don't get peristent errors from somehow mis-set persistents
                          disp(ME.getreport)
                          rooot='';
                          urls='';
                       end
                   end

               end

           end

           function getDir()

                persistent d
                if isdir(d), cd(d); end

                di=uigetdir;
                if di~=0
                    d=di;
                    set(h.editRoot,'string',d);
                end

           end

           function filterlist()

                urls=getlistData('urls');
                if isempty(urls)
                    searchfunction;
                    urls=getlistData('urls');
                end


                rooot=getlistData('root');

                norig=length(urls);

                % Cut off the root
                urls=cellfun(@(x)x(length(rooot)+1:end),urls,'uniformoutput',false);

                % Filter for cat...
                urls=filters(urls,get(h.editCat,'string'));

                % Filter for the stage (because it doesn't feel right to call it penetration)
                urls=filters(urls,get(h.editStage,'string'));

                % Filter for Experiment Type
                urls=filters(urls,get(h.editExt,'string'));

                % Shorten List String
                set(h.listSearch,'String',urls);
                set(h.textSearch,'String',sprintf('Displaying %g filtered out of %g total results',length(urls),norig));

            end

           function F=getlistData(field)

                if isempty(get(h.listSearch,'UserData'))
                    F=[];
                else
                    S=get(h.listSearch,'UserData');

                    F=S.(field);

                end
           end

           function putupList(urls,rooot)

               setlistData('root',rooot);
               setlistData('urls',urls);
               set(h.listSearch,'string',urls);
               set(h.textSearch,'string',sprintf('Found %g mat files in root',length(urls)));


           end

           function setlistData(field,value)

                if ~isempty(get(h.listSearch,'UserData'))
                    F=get(h.listSearch,'UserData');
                end

                F.(field)=value;   

                set(h.listSearch,'UserData',F);

            end

           function listpush(dest,number)
                % Number is optional, otherwise the selected item is pushed
                if ~exist('number','var')
                    number=get(h.listSearch,'value');
                elseif isempty(number)
                    set(dest,'string',''); return;
                elseif (isnan(number))
                    set(dest,'string','n/a'); return;
                end

                list=get(h.listSearch,'string');
                if ~isempty(list)
                    rooot=getlistData('root');
                    fullurl=[rooot list{number}];
                    set(dest,'string',fullurl);
                end

           end

           function autoAdd()
               % Automatically add items to list based on filters



               if isempty(h.editCat) || isempty(h.editStage);
                   hw=warndlg('First fill in a Cat and a Stage!');
                   uiwait(hw);
                   return;
               end

               filterlist;

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
               kat=get(h.editCat,'string');
               id=get(h.editExt,'string'); % like "P4C1"
               stg=get(h.editStage,'string'); % like "tuning2"
               tok=[stg '_' id]; % like "P4C1_tuning2" 
               list=get(h.listSearch,'string');


               % For each file, if a unique file is found it'ing it, add it.
               listpush(h.editSpike,scanfor(list,[filesep 'times_' tok '_Voltage1.mat']));
               listpush(h.editData,scanfor(list,[filesep tok '.mat']));
               listpush(h.editVoltage,scanfor(list,[filesep tok '_Voltage1.mat']));
               listpush(h.editEEG,scanfor(list,[filesep tok '_EEG_1.mat']));
               listpush(h.editPhoto,scanfor(list,[filesep tok '_Photodio1.mat']));
               listpush(h.editPSTH,scanfor(list,['(movies' filesep 'psth_)*' stg '.mat']));
               listpush(h.editStim,scanfor(list,['stimuli' filesep 'cat' kat '_' tok '.mat']));

               % *psth one is a little complicated, cause they only exist for movies now

               % Detect the type
               detect=@(toks) any(~cellfun(@isempty,regexpi(get(h.editExt,'string'),toks)));
               setval=@(str) set(h.popType,'value',find(strcmp(str,get(h.popType,'string')),1));
               if detect ({'whitenoise','inversetime'})
                   setval('whitenoise')
                   listpush(h.editStimTime,nan);
               elseif detect({'tuning'})
                   setval('tuning')
               elseif detect({'movies'})
                   setval('movies')
                   
                   % Set movie clips folder
                   clipdir='/projects/kevan/StimulusPresentation/Movie/Clips';
                   if isdir(clipdir)
                        set(h.editStim,'string',clipdir);
                   end
               end

           end

           function addURLfields(props)

               [yep,ix]=ismember(props,A.links(:,1));

               if ~all(yep)
                  error(['You tried to add a URL-box for property "%s", but '...
                      'it''s not listed  in "Links" so we don''t know what GUI '...
                      'component to link it to.  See property "Links" and add it'],...
                      props(find(yep,1)));
               end

               % 
               genericHandles=[h.pushXXXAdd h.editXXX h.pushXXXFind];
               uihandles=cell2mat(struct2cell(h)); uihandles=uihandles(2:end);

               ypos=@(y)arrayfun(@(x)get(x,'position')*[0 1 0 0]',y);
               offset=2.2*(length(ix):-1:1);
               tomove=uihandles(ypos(uihandles) >= min(ypos(genericHandles)));  


               % Expand figure
               set(0,'units','characters');set(h.figure1,'units','characters');
               fpo=get(h.figure1,'position'); spo=get(0,'ScreenSize');
               fpo(4)=fpo(4)+offset(1);
               if fpo(2)+fpo(4)>spo(4),fpo(2)=spo(4)-fpo(4); end
               set(h.figure1,'position',fpo);

               % Add the files
               arrayfun(@(ind,off)addURLfield(A.links{ind,1},A.links{ind,2},off),...
                   ix,offset+ypos(genericHandles(1)));

               % Move shit to make room
               arrayfun(@(x)set(x,'position',get(x,'position')+[0 offset(1) 0 0]),tomove);

           end

           function addURLfield(propname,fieldname,offset)
               % Adds a "load file" field with all functionality.
               % Important convention: the name of the associated 

               % Copy uicontrols, add their functionality
               parent=get(h.pushXXXAdd,'parent');
               hAdd=copyobj(h.pushXXXAdd,parent);
               hEdit=copyobj(h.editXXX,parent);
               hFind=copyobj(h.pushXXXFind,parent);
               set(hAdd,  'callback',@(e,s)listpush(hEdit),'string',[propname '>>']);
               set(hFind, 'callback',@(e,s)manualsearch(hEdit, ['Get ' propname]));

               % Move to right location.
               moveoff=@(x)set(x,'position',get(x,'position').*[1 0 1 1]+[0 offset 0 0]);
               moveoff(hAdd);
               moveoff(hEdit);
               moveoff(hFind);

               % Store the handles
               h.(['add_'  propname])=hAdd;
               h.(fieldname)=hEdit;
               h.(['find_' propname])=hFind;
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
       
       function playMovie(m,hF)
          % Play a movie given the 3-D matrix m
          
          
          
          if nargin<2
              hF=figure;
          end
          
          U=UIlibrary;
          [hB val]=U.buttons(2,{'Play','Reset'});
          
          lims=quickclip(m);
          
%           hF=figure;
          figure(hF);
            colormap (gray);
          for i=1:size(m,3)
              if ~ishandle(hF), return; end
              imagesc(m(:,:,i),lims);
              drawnow;              
          end
          
       end
           
           
   end
        
end




