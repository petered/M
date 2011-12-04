classdef InfoClass < handle
    % This class produces an object (let's call it Info), which returns all
    % information related to the experiment's synchronization signal.  
    
    properties
        
        Ctick;              % Synch signal "ticks" in alog signal.  Indexed as (toggle#,trial#) 
        
        Cut;                % Synch signal ticks marking edge of trial.  Indexed as (start/end,trial#)
        
        rawlength;          % Lengh of full, uncut input in alog signal samples
        synclength;         % Length of full synch signal
        
        
        % Same as above but for resampled indeces
        ReCut;        
        ReCtick;
                
        buffer;             % Buffer (in seconds) of time collected from each trial outside of Cut
        
        ToggleRate;         % Median rate of the toggle signal
        
        conditions;         % Condition vector: One condition assigned to each trial
        
    end
    
    properties (Dependent=true)
        scalingratio;
        TrialLength;
        ReTrialLength;
        nTrials;
    end
    
    methods     % Get methods for dependents
        
        function res=get.TrialLength(A)
            res=A.Cut(2,1)-A.Cut(1,1)+1;
        end
            
        function res=get.ReTrialLength(A)
            res=A.ReCut(2,1)-A.ReCut(1,1)+1;
        end
        
        function res=get.nTrials(A)
            res=size(A.Ctick,2);
        end
        
        function res=get.scalingratio(A)
            res=A.rawlength/A.synclength;
        end
        
    end
    
    
    
    methods
        
        function Info=InfoClass(PF)
            %% Chopper. 
            % This program takes the synch signal, and returns information gained from
            % reading this signal.  This is returned in the structure Info. 

            % Info has the following fields:
            % FIELD        DESCRIPTION
            % Cut(i,j)     Matrix of experiment times (as measured by sample
            %              number from start).  First row indicates start
            %              times, second indicates stops.
            % Ctick{j}     Record up and down ticks in the analog channel.
            %              Each cut j has the ticks in Info.Ctick{j} inside it.
            % Condition(i) Condition of trial i.

            % INPUT        %DESCRIPTION
            % synch        The synch signal being used.  (Analog 7 in our case).  
            % PF           The structure containing information on the experiment.
            %              parameters.

            %% General Params

            % Load for easy reference
            
            
            % Get synchronization channel
            synch=[];
            for i=1:length(PF.block)
                M=load(PF.block{i}, PF.sync);
                synch=[synch; M.(PF.sync)];
            end
            clear M;
            
            
            disp('Choppin` the block...');
            synclink=['<a href="matlab: load ''' PF.block{1} ''' ''' PF.sync '''; plot(' PF.sync ') ;">here</a>'];
            
            try
                
            % Error messages.
            if isempty(synch)
                error(['The sync signal, ' PF.synch ' from ' PF.experimentID ' could not be found!']);
            elseif length(synch)==1
                error(['Something''s wrong with the sync signal, ' PF.synch ' from ' PF.experimentID '.  It consists of just 1 sample.']);
            end
                        
            % Get scaling ratio (Because those jerks sample alog and neur
            % at different rates)
            a=whos( '-file', PF.block{1}, PF.sync, 'neur1');
            Info.rawlength=max(a(2).size);
            Info.synclength=max(a(1).size);
                               
            % Detect Rising edges: (INTERNAL FUNCTION .. see below)
            [Tick delta]=getTicks(synch,PF.SyncThresh);
            
            % Vector representing the spacing between regular ticks
            Info.ToggleRate=PF.SampleRate/Info.scalingratio/median(delta);
                      
            
            %% Chop
            
            
            switch lower(PF.SyncMethod)
                case 'continuous'
                   %% Sebastien's method                

                    [Info.Ctick Info.Cut]=getContinuous(Tick, ppex); % (INTERNAL FUNCTION .. see below)
%                     Info.nTrials=size(Info.Cut,2);
                    
                    Info.buffer=0;
                    if ~isempty(PF.buffer)
                        disp('  Warning: Buffer is not supported in continuous SynchMethod mode.  Ignoring buffer argument.');
                    end

                case 'volley'
                    %% Shmuel's method, sebastien's new method.
                  

                   

                    % For spontaneous, take the whole thing
                    RatioThresh=4; % minimum ratio between the inter-trial gap and the intra-trial tick spacing 
                    [Info.Ctick]=getTrialTicks(Tick, delta, RatioThresh); % (INTERNAL FUNCTION .. see below)
                        
                    
                     % Set up desired buffer
                    if isnumeric(PF.buffer), buff=ceil(PF.buffer*PF.SampleRate/Info.scalingratio);   
                    else buff=PF.buffer; % Automatic
                    end
                    
                    enoughtrials=5;
                    % This parameter decides when there've been enough trials that
                    % it's now worth it to cut trials off the end rather
                    % than to shorten the buffer because not enough
                    % buffer-time has been left at the end.
                    
                    buffer=Info.getCuts(buff,enoughtrials);  % (INTERNAL METHOD .. see below)
                                        
                    Info.buffer=buffer*Info.scalingratio/PF.SampleRate; 
                    
                    

                    

                otherwise
                    %% Default: take the whole thing    

                    if ~strcmpi(PF.SyncMethod,'full')
                        disp('  Warning: No known synchronization method used... Taking full interval')
                    end
                    
                    Info.Cut(1:2,1)=[1 length(synch)];
                    Info.Ctick=Tick;

            end
            
            catch ME
                disp 'An error occurred when decoding the syncronization signal.'
                disp (['View the sync signal ' synclink])
                disp 'Error shown below:'
                disp ---------------
                
                rethrow(ME);               
            end

            Info.conditions=setconditions(PF.conditions,Info.nTrials);  % (INTERNAL FUNCTION .. see below)
            
            % Function to transfer old sample Indeces to New
            Tss=@(x)ceil(x*PF.ResampleRate*Info.scalingratio/PF.SampleRate);

            % Transfer all Sampled Indeces to new sample rate
            Info.ReCut(1,:)=Tss(Info.Cut(1,:));
            ReTrialLength=Tss(Info.Cut(2,1))-Info.ReCut(1,1)+1;
            Info.ReCut(2,:)=Info.ReCut(1,:)+ReTrialLength-1;
            Info.ReCtick=Tss(Info.Ctick);
                
                

%             S=Info;
            
            fprintf 'Done.\n'

        end
        
        
        
        
        function buffer=getCuts(Info,buffer,enoughtrials)
            % This guy takes the trial-wise toggle signal, and the desired buffer
            % as an input, and sets the "Cut" property.   If
            % necessary, it will also modify the "Ctick" property by
            % cutting the last trial.
            
            cutlength=max(Info.Ctick(end,:)-Info.Ctick(1,:));
            Cuts=[Info.Ctick(1,:);  Info.Ctick(1,:)+cutlength];

            % Auto or user selected buffer:
            if isempty(buffer)
                buffer=0;
            elseif strcmpi(buffer,'auto')
                if Info.nTrials>1
                    buffer=fix(median( Info.Ctick(1,2:end)-Info.Ctick(end,1:end-1) )/2);
                else
                    buffer=min(Info.Ctick(1)-1,Info.synclength-Info.Ctick(end));
                end
            elseif ~isnumeric(buffer)
                error('You entered "%s" for your buffer.  This is not recongnised.  We buffer can be a number, an empty matrix, or ''auto'', buffer');
            end

            % These lines deal with reconsiling the desire to have lots of
            % buffer space around your trials with the desire to keep all 
            % the trials.  They should only make a difference if the 
            % experimentor has been reckless and not left enough buffer 
            % room at the beginning and end of experiments.
            if buffer>Cuts(1)-1                                   % Make sure buffer doesn't cause negative indeces
                disp '  WARNING: Not enough buffer-time was left at the start of the experiment... Buffer is being shortened to fit'
                buffer=Cuts(1)-1;                                 
            end
            if buffer>Info.synclength-Cuts(end)                            % If current buffer would cause an "index exceeds matrix dimensions"
                fprintf('  WARNING: Not enough buffer-time was left at the end of the experiment... ')
                if Info.nTrials < enoughtrials                             % If there are too few trials to cut any, shorten the buffer to fit, if necessary
                    disp 'Buffer is being shortened to fit.'
                    buffer=Info.synclength-Cuts(end);                      % Make sure buffer doesn't exceed dimensions.
                else                                                       % If there are enough trials, just cut the last one.
                    disp('Truncating last trial.')
                    Info.Ctick(:,end)=[];
                    Cuts(:,end)=[];
                end
            end
            
            Cuts(1,:)=Cuts(1,:)-buffer;
            Cuts(2,:)=Cuts(2,:)+buffer;
            
            % Save Cuts and save buffer in time-form.
            Info.Cut=Cuts;
            
                    
            % Error if cuts don't end up in signal.  This error
            % should not be possible, but is kept here as a check.
            if Info.Cut(end)>Info.synclength||buffer<0
                error(['Your trial boundaries exceed '...
                    'the length of your data.  This should be impossible. ',...
                    'Try reducing your buffer or debugging this file or '...
                    'setting PF.buffer to ''auto'' or '...
                    'just calling peter to fix it.']); 
            end
            
            
        end
        
        
        
        
    end
    
    methods % Property-like methods
        
        
        
        
    end
        
    
end



function [Tick delta]=getTicks(synch,thresh)
    % This function finds the toggles in a fairly sturdy way.  

    % Get Frame Toggles
    if synch(1)<thresh,             order=[1 2];
    else                            order=[2 1];
    end;     
    
    temp=find(synch(2:end)>thresh & synch(1:end-1)<=thresh)+1;
    if isempty(temp)
        error(['Synchronization toggle signals not found... have a look at \n'...
            'the sync signal (link above).  It may be that the threshold \n'...
            'is too high or that the signal''s messed up.'])
    end
    
    Tick=nan(2,length(temp));
    Tick(order(1),:)=temp; % Rising Edges
    % Truncate last one if signal starts sub-thresh, ends super-thresh
    if (synch(1)<=thresh && synch(end)>thresh), Tick(:,end)=[]; end
    % Detect falling edges
    Tick(order(2),:)=find(synch(2:end)<=thresh & synch(1:end-1)>thresh,size(Tick,2))+1; % Falling Edges


    % The signal can be sloppy.  The following lines perform
    % debouncing and eliminate ticks that just occur out of the
    % blue for no good reason.
    delta=diff(Tick);
    ix=delta<median(delta)/10;
    Tick(:,ix)=[];
    Tick=Tick(:);

    delta=diff([Tick; length(synch)]);
end

function TrialTicks=getTrialTicks(Tick, delta, RatioThresh)
    % This guy takes in the vector delta, which represents spacing between
    % ticks, and spits out the ticks in a reshaped vector, such that
    % they're separated by trial.  

    if ~exist('RatioThresh','var'), RatioThresh=5; end
    
    CutSt=find(abs(delta)>RatioThresh*median(delta));
    % Represents the number inter-tick-interval numbers
    % corresponding to the gaps between trials.  For
    % example, if a trial has 120 ticks, CutSt(1) will be
    % 120, indicating that on the 120th interval, there is
    % a large gap in between ticks, indicating that a new
    % trial has started.


    badtrials=false(length(CutSt));
    
    inconsitent=diff(diff([0; CutSt]))~=0;
    if all(inconsitent)
        disp('Warning: We detected a spurious lag in your synch signal.  It is being dealt with humanely, and should not be an issue');
        CutSt=CutSt(end);
        
    elseif any(inconsitent),   % If any middle trials contain different numbers of toggles
       disp(['Reading frame toggle indicates that different '...
            'trials have different lengths.  This may arise '...
            'out of a problem with your frame toggle signal.  '...
            'In the meantime, we''ll fix '...
            'the bad trials.']);

        badtrials = diff([0; CutSt])~=mode(diff([0; CutSt]));
    end

    tickpertrial=median(diff([0;CutSt]));

    % Record Ticks in each trial, edge ticks, condition of each tick
    TrialTicks=nan(tickpertrial,length(CutSt));
    startix=([0;CutSt(1:end-1)]+1);
    for i=1:length(CutSt)
        if ~badtrials(i), TrialTicks(:,i)=Tick(startix(i):CutSt(i));
        else
            disp (['WARNING: BAD TOGGLE SIGNAL ON TRIAL ', int2str(i) '. FIXING IT..']);    
            TrialTicks(:,i)=round(linspace(Tick(startix(i)),Tick(CutSt(i)),tickpertrial));
        end
    end

    

end



function [TrialTicks Cuts]=getContinuous(Tick, ppex)


    if mod(length(Tick),ppex)~=0,
        disp(['WARNING: The stated amount of frame toggles per trial, ' int2str(ppex) ', does not '...
            'multiply evenly into the total number of frame toggles, ' int2str(length(Tick))  ...
            '.  Truncating to the nearest trial.']);
    end

    % Get indeces of trial edges
    TrialTicks=reshape(Tick(1:ppex*fix(length(Tick)/ppex)),ppex,[]);  

    Cuts=[TrialTicks(1,:) ; TrialTicks(1,:) + min(TrialTicks(end,:)-TrialTicks(1,:))];
                    
end

function conditions=setconditions(condlist,nTrials)
    % Figure out what trial belongs to which condition.  Assumes: nan's
    % mean "cycle through previous ones", inf's mean "repeat last one".
    
    
        if length(condlist)>=nTrials % If there are more conditions specified than number of trials
            conditions=condlist(1:nTrials);
        else
            fstnan=find(isnan(condlist));
            fstinf=find(isinf(condlist));
            if ~isempty(fstnan)     % If there's a nan, recycle conditions
                cond=repmat(condlist(1:fstnan-1),[1 ceil(nTrials/(fstnan-1))]);
                conditions=cond(1:nTrials);
            elseif ~isempty(fstinf) % If there's an inf, repeat the last one.
                conditions=[condlist(1:fstinf-1) repmat(condlist(fstinf-1), [1 nTrials-length(condlist)+1])];
            else
                disp 'WARNING: NOT ENOUGH EXPERIMENTAL CONDITIONS SPECIFIED FOR NUMBER OF TRIALS.  INFO.CONDITIONS WILL BE LEFT BLANK'
                conditions=[];
            end
        end

end
