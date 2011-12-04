classdef JointAction < handle
    
    properties
        
       % Parameters of Experiment
       ExpNo;           % Eg 23
       SubjNo;          % Eg [43 12 53]       
       cond;            % eg. 1,2,3       
       group;           % Group #       
       position;        % Subject Position(s)       
       waveforms;       % Stores the 4 inputs (3 buzzers + phododiode)
              
       % Trial-by-trial parameters (NxM matrices, where N=number of subjects, M=#blocs*#trialsperblock
       times;           % Extracted from waveform data.
       stim;            % Stimulus type (1-9)
       block;           % 1-4
       correct;         % Correct Count
       error;           % Error Count
       noreaction;      % No-Reaction?
              
       currentStatus='Not Started';    % Text id'ing experiment status
       
       collectionmode='keyboard' % either 'keyboard' or 'analog'
       
       
       % Other Locally Used Properties
       n_trial;         % Number of trials
       n_block;         % Number of blocks
       square_width;    % Width of square
       ai;              % Analog input
       buzzerChans;     % Channels for buzzer
       photoChan;       % Channel for photoDiode
       
    end
    
    %% Experiment Presentation [Edit these functions to change experiment conditions]
    
    methods % Experiment Presentation
        
        function RunRun(A) % More Condensed Version of RunRunRun.. needs to be tested
            % ============Configuration & Initialization===================
            
            % See Configuration File "JA_Configure"
            A.Configure;
            A.currentStatus='Started-Not Complete';
            
            % Initialize Results Matrix
            [A.times A.stim A.block A.correct A.error A.noreaction]=...
                deal(zeros(length(A.SubjNo),A.n_trial*A.n_block));
                        
            % Start Cogent and get welcome screen going
            start_cogent;
            A.Start_Screen;
                        
            % ===============Experiment Loop======================
            for j = 1:A.n_block % For each block

                % Show Start-of-Block Screen
                A.Block_Start(j);
                
                % Get a random permutation of Trials 
                n = A.n_trial;
                StimulusList=A.getStimList(n);
                
                for i=1:n % For each stimulus round
                    
                    % Run cycle of stimulus, get timing feedback
                    [k keyout rt]=S.Stim_Cycle(StimulusList(i));
                    
                    % Interpret Results
                    status=A.Interpret(keyout,k); 
                    if strcmp('status','quit'), stop_cogent; return; end
                    [correct err noreaction]=cellfun(@A.getStatus,status); 
                    
                    % Store into results matrix
                    ix=(j-1)*n_trial+i;
                    A.times(:,ix)         =rt;
                    A.stim(:,ix)          =Stimulis;
                    A.block(:,ix)         =j;
                    A.correct(:,ix)       =correct;
                    A.error(:,ix)         =err;
                    A.noreaction(:,ix)    =noreaction;

                end;
            end;

            % Re-arrange by stimulus number
            A.sortby('stim');
            
            % Stop cogent and exit program
            S.stop_cogent;
            A.currentStatus='Complete';
            
        end
        
        % =========Sub-Functions for all Conditions==============
        
        function Configure(A) % Configuration File
            
            % Clear Workspace, Command Window and close all
            rand('state', sum(100*clock)); % initialize random number generator

            % Variabel definition
            n_block      = 4; % here you can change the number of blocks
            n_trial      = 108; % here you can change the number of trials per block
            square_width = 100; % squarewidth

            % Display configuration
                mode              = 1; % window mode ( 0=window, 1=full screen ), you can let that like this
                resolution        = 3; % screen resolution (1=640x480, 2=800x600, 3=1024x768, 4=1152x864, 5=1280x1024, 6=1600x1200), you can change that, depending on the resolution of your screen and the size of the stimuli you want to hav
                bkrd_col          = [0.05,0.05,0.05]; % background colour dark grey in RGB-code [reg,green,blue], here you can change, if we need a brighter background for the children
                fore_col          = [1,1,1]; % foreground colour white in RGB-code [reg,green,blue], that means fixation cross and font
                fontname          = 'Arial narrow'; % name of font       
                fontsize          = 60; % size of font
                number_of_buffers = 20; % number of offscreen buffers, just let that like it is, we don't need more
                number_of_bits    = 32; % number of bits per pixel (8=palette mode, 16, 24, 32, or 0=Direct mode, maximum possible bits per pixel), don't know what that is and if we can change that
                config_display(mode, resolution, bkrd_col, fore_col, fontname, fontsize, number_of_buffers, number_of_bits);

            % Keyboard configuration
                qlength           = 100; % maximum number of key events recorded between each keyboard read.
                resolution        = 1; % timing resolution in ms.
                mode              = 'nonexclusive'; % device mode (�exclusive� or �nonexclusive�), it's told to change that from �nonexclusive� to �exclusive� when running the experiment, but I prefer to tell the subjects and work with �nonexclusive�, 'cause abort is then easier           
                config_keyboard(qlength, resolution, mode);    

            A.collectionmode='analog';
            %--------------------------------------------------------------
            % Save required properties
            A.square_width=square_width; %#ok<*PROP>
            A.n_trial=n_trial;
            A.n_block=n_block;
            
            A.buzzerChans=[1 2 3];
            A.photoChan=0;
            
            
            % Setup Analof input device
            if strcmp(A.collectionmode,'analog')
                A.ai = analoginput('nidaq','Dev1');
                addchannel(A.ai,[A.photoChan A.buzzerChans]);
            end
        end

        function Start_Screen(A) % Welcome Screen 
                        
            % Load required properties
            square_width=A.square_width;
            
            % Welcome slide
                clearpict(13); 
                cgtext('Willkommen zum Experiment.',0,100);

            % Fixation-cross slide
                clearpict(2); % clear graphics buffer 2 and set buffer 2 as active following graphics commands are written to buffer 2
                cgpencol(1,1,1); % set drawing color to white
                cgpenwid(1);
                cgdraw(-5, 0, 6, 0); % draws horizontal line of the fixation cross, 'cause 0,0 is the center of the screen
                cgdraw(0, -5, 0, 6); % draws vertical line of the fixation cross, 'cause 0,0 is the center of the screen

            % Instructions slide
                clearpict(12);
                cgtext('Aufgabenstellung:',0,0);

                if any([A.cond==[1 2] (A.cond==3 && A.position==1)])
                clearpict(11);
                cgpenwid(5);
                cgpencol(1,0,0);
                cgrect(-512+square_width/2+80,250,square_width,square_width);
                cgflip;
                cgtext('bei rot dr�cke die linke Taste',-410+square_width/2+400,250);
                end
                
                if any([A.cond==[1 2] (A.cond==3 && A.position==2)])
                cgpenwid(5);
                cgpencol(0,1,0);
                cgrect(-512+square_width/2+80,0,square_width,square_width);
                cgflip;
                cgtext('bei gr�n dr�cke die mittlere Taste',-380+square_width/2+400,0);
                end

                if any([A.cond==[1 2] (A.cond==3 && A.position==3)])
                cgpenwid(5);
                cgpencol(0,0,1);
                cgrect(-512+square_width/2+80,-250,square_width,square_width);
                cgflip;
                cgtext('bei blau dr�cke die rechte Taste',-390+square_width/2+400,-250);
                end
                
            %Start slide show
                clearpict;
                drawpict(13);
                waitkeydown(inf,[]);

                drawpict(12);
                waitkeydown(inf,[]);

                drawpict(11);
                waitkeydown(inf,[]);

            
        end
        
        function Block_Start(S,blockno)  %#ok<MANU> % Play at Block-Start 
              
            % the following text is for the investigator to help him overlook the experiment
            clearpict(1);
            cgtext(['Das ist der ',num2str(blockno),'. Block'],0,0);
            drawpict(1);
            waitkeydown(inf,[]);

            % Instructions for each block
            drawpict(11);
            waitkeydown(inf,[]);

            
            % If you wan to make different block-start actions for each
            % condition, add the below funcitons and enable this code:
%             switch S.cond
%                 case 1
%                     varargout=C1_Block_Start(S,varargin{:});
%                 case 2
%                     varargout=C2_Block_Start(S,varargin{:});
%                 case 3
%                     varargout=C3_Block_Start(S,varargin{:});
%             end
            
        end 
          
        function [rt, status]=Stim_Cycle(A,Stimulus)   % Play in stimulation loop
           % rt is reaction time
           % status is : c-correct, e-error, or n-noreaction
            
                        
            % Collect timing and status
            switch A.collectionmode
                case 'keyboard'
                    
                    A.ShowStim(Stimulus);
                    
                    % get reaction time and write to file
                    clearkeys (); 
                    start_time = drawpict(3); % present graphics buffer 3 and start counting the RTs
                    readkeys (); % get key presses only (no key relases)
                    waitkeydown(3000, []); % present display as long as any of the predefined buttons is pressed, maximum for 3000ms = 3 sec

                    [keyout, end_time, numberofkey] = getkeydown;
                    if numel(keyout)>0, rt = end_time(1) - start_time; % Reaction time
                    else rt=0;
                    end

                    switch Stimulus
                        case {1 2 3}, k=1;
                        case {4 5 6}, k=71;
                        case {7 8 9}, k=12;
                        otherwise, error('Invalid Stimulus: %g',Stimulus);
                    end
                    status=A.Interpret(keyout,k); 
                    
                case 'analog'
                    
                    start(A.ai);
                    
                    A.ShowStim;
                    
                    clickfunction=@(x)x<2.5;
                    
                    switch Stimulus
                        case {1 2 3}, channel=A.buzzerChans(1);
                        case {4 5 6}, channel=A.buzzerChans(2);
                        case {7 8 9}, channel=A.buzzerChans(3);
                        otherwise, error('Invalid Stimulus: %g',Stimulus);
                    end
                    
                    A.waitforbuzzer(A.ai,channel,clickfunction,10)
                
                    stop(A.ai);
                    
                    [rt status]=A.getAIresults;
                    
                    
                    
                    
                    
            end
                
        end 
                
        function ShowStim(S,Stimulus) % Condition 1: Stimulus cycle
            
            square_width=S.square_width;
            
            drawpict(2); % Fixation cross display
            wait(1200);
            clearpict;       
            stimulusDraw(Stimulus,square_width); % Stimulus draw

        end
        
        %=======================
        
        function sortby(A,prop)
            
            [~,ix]=sort(A.(prop));
            A.times=A.times(:,ix);
            A.stim=A.stim(:,ix);
            A.block=A.block(:,ix);
            A.correct=A.correct(:,ix);
            A.error=A.error(:,ix);
            A.noreaction=A.noreaction(:,ix);
            
        end
        
        function saveAIdata(A,data,block,trial)
            
            
            
        end
        
        function [rt status]=getAIresults(A,clickfunction,channel)
            % rt is reaction time
            % status is : c-correct, e-error, or n-noreaction
            
            % Grab Data From Device
            [data time] = getdata(A);
            chans=get(ai,'Channel');
            
            % Get starttime based on transition of photodiode
            photoix=find(chans==A.photoChan,1);
            photoTime=signalscan(data(:,photoix));
            if isempty(photoTime)
                disp 'WARNING-DID NOT DETECT PHOTODIODE TRANSISTION~ RT WILL BE INCORRECT!'
                photoTime=1;
            else
                photoTime=photoTime{1}(1);
            end
            
            % Get first press times of each buzzer
            [~,chanix]=ismember(A.buzzerChans,chans);
            clicktimes=arrayfun(@(ix)find(clickfunction(data(:,ix)),1),chanix,'UniformOutput',false);
            
            % Set Up reaction times
            rt=zeros(size(clicktimes));
            responses=cellfun(@(x)~isempty(x),clicktimes);
            rt(responses)=time(cellfun(@(x)x(1),clicktimes(responses)))-...
                          time(photoTime);
                          
            % Set Up statuses
            correctchan=find(chans==channel);
            status=char(size(rt));
            status(~responses)='n';                 % No reachtion
            status(responses & correctchan) = 'c';  % Correct Reaction
            status(responses & ~correctchan) = 'e'; % Bad reaction
                       
            
        end
        
    end   
    
    methods (Static) % Static methods on experiment presentation
        
        function [correct err noreaction]=getStatus(status)
           %This is a bit silly, and should be gotten rid of.
           % (replaced with a single symbol indicating whether if was a
           % correct, error, or noreaction)
           switch status
               case 'c',    correct=1;err=0;noreaction=0;
               case 'e',    correct=0;err=1;noreaction=0;
               case 'n',    correct=0;err=0;noreaction=1;
           end
        end
        
        function StimulusList=getStimList(n)
            
            
            function [stimulus] = stimulusN(trial,x)
                if trial >= 1 && trial <= x/9
                stimulus = 1;% Square on the left side and red
                elseif trial >= x/9+1 && trial <= 2*x/9
                stimulus = 2;% Square in the center and red
                elseif trial >= 2*x/9+1 && trial <= 3*x/9
                stimulus = 3;% Square on the right side and red
                elseif trial >= 3*x/9+1 && trial <= 4*x/9
                stimulus = 4;% Square on the left side and green
                elseif trial >= 4*x/9+1 && trial <= 5*x/9
                stimulus = 5;% Square in the center and green 
                elseif trial >= 5*x/9+1 && trial <= 6*x/9
                stimulus = 6;% Square on the right side and green
                elseif trial >= 6*x/9+1 && trial <= 7*x/9
                stimulus = 7;% Square on the left side and blue
                elseif trial >= 7*x/9+1 && trial <= 8*x/9
                stimulus = 8;% Square in the center and blue
                elseif trial >= 8*x/9+1 && trial <= x
                stimulus = 9;% Square on the right side and blue
                else
                    error('No stimulus was assigned in getStimulusList.. error in this function');
                end;
            end
                        
            RandomList = randperm(n);
            StimulusList = zeros(n,1);
            for i=1:n % Why is this a separate loop from the next one?
                StimulusList(i)=stimulusN(RandomList(i),n);
            end;
            
        end
        
        function TO=waitforbuzzer(ai,channel,endcond,timeout)
            % ai is the ai object
            % channel is the channel(s) to look at
            % endcond is a boolean function handle that evaluates to true when the sample from the channel is tested.
            % timeout (optional) is the timeout
            if ~exist('timeout','var'), timeout=Inf; end
            TO=false;
            
            chans=get(ai,'Channel');
            ix=find(chans==channel,1);
            
            samp=getsample(ai);
            tic;
            while ~(any(arrayfun(endcond,samp(ix))))
                if toc>timeout
                   TO=true;
                   return;
                end
                
            end
            
        end
        
    end
    
    %%
    
    methods % User Interface
                
        function status=New_Experiment(A,JA,expNo)
            
            status=false;
            
            
            S=JA.S; % Ugh.. confusing, but you gotta pass the JA object otherwise you lose additions to S
            
            
            confirm=false;
            while ~confirm
                
                fprintf ('== NEW EXPERIMENT (#%g) ==\n',expNo);
                condi=enterfield('Enter Condition (1,2,3)',@(x)length(x)==1&&any(x==[1 2 3]),'Condition must be 1,2 or 3',true);
                
                switch condi
                    case {1 3}
                        number=enterfield('Enter Subject Number',@(x)length(x)==1,'Just one subject number',true);
                    case 2
                        number=enterfield('Enter 3 Subject Numbers', @(x) length(x)==3,'There must be 3 subjects!',true);
                    otherwise %should never get here
                        disp 'Invalid condition number (pick 1-3)', continue;
                end
                
                if max(number)>length(S)
                    S(max(number)).number=[];
                end
                empties=cellfun(@isempty,{S(number).number} );
                if any(empties)
                    res=questdlg(['Subject(s) ' int2str(number(empties)) ' have not yet been created.'],'New Subjects','Create','Cancel','Create'); 
                    switch res
                        case 'Create'
                            
                            instatus=JA.Make_Subjects(number(empties)); 
                            
                            if ~instatus, return; end % If cancelled 
                            
                        case 'Cancel', return;
                    end
                
                end
                
                switch condi
                    case 1
                        group=nan;
                        position=enterfield('Enter Position Number',@(x)length(x)==1&&any(x==[1 2 3]),'One number for position',true);
                    case 2
                        group=enterfield('Enter Group Number',@(x)length(x)==1,'Must provide a single number for this group',true);
                        position=enterfield('Enter 3 Position Numbers',@(x)length(x)==3 && isequal(unique(x),[1 2 3]),'Must input 3 numbers in range 1-3',true);
                    case 3
                        group=enterfield('Enter Group Number',@(x)length(x)==1,'Must provide a single number for this group',true);
                        position=enterfield('Enter Position Number',@(x)length(x)==1&&any(x==[1 2 3]),'One number for position',true);
                end
                
                
                txt=sprintf(['Experiment %g: \n'...
                    '------------------\n'...
                    'Condition: %g\n'...
                    'Subject(s): %s\n'...
                    'Group: %g\n' ...
                    'Position(s): %s\n'],expNo,condi,int2str(number),group,int2str(position));
                    
                res=questdlg(txt,'Confirm Experiment','Confirm','Re-Enter','Cancel','Confirm');
                switch res
                    case 'Re-Enter'
                        disp 'Changes not saved.  Re-Enter Data:'
                    case 'Cancel'
                        return;
                    case 'Confirm'
                        confirm=true;
                end
                                    
            end
            
            % Add to list and close up
            A.ExpNo=expNo;
            A.cond=condi;
            A.SubjNo=number;
            A.group=group;
            A.position=position;
            fprintf ('-- EXPERIMENT %g Created --\n',expNo);
            status=true;
            
            
        end
        
    end
    
    methods % Running things
        
        function [status]=Interpret(A,key,target)
            if key==52, status='quit'; return; end
            switch A.cond
                case 1
                    if isempty(key), status='noreaction';
                    elseif key==target, status='correct';
                    else status='error';
                    end
                case 2
                    
                case 3
                    
            end
            
        end
        
        function gettimes(A)
            
            % Some Code to extract times from waveform data
            
           A.times=something (A.waveforms); 
            
        end
        
        function ConfirmTimes(A)
            
            % Plot the times from wf data.
            
        end
        
        function ChangeTime(A)
            
            
            
        end
        
                
    end
    
    methods % IO Methods
                
        function [SUCCESS,MESSAGE]=WriteToExcel(A,S,xlsx_name,line)           
            
            SUCCESS=true;
            while true
                
                if ~SUCCESS
                    txt=sprintf(['Write failed with message\n------\n%s\n-----\n'...
                        'It may be that you have the excel file open in another window.  '...
                        'If so, close the window and try again.  Otherwise, you can cancel '...
                        'the write'], MESSAGE.message);
                    res=questdlg(txt,'Write Failed','Try Again','Cancel Write','Try Again');
                    switch res
                        case 'Try Again'
                            SUCCESS=true;
                        case 'Cancel Write'
                            return;
                    end
                end
                
                fprintf('Saving Experiment %g to Spreadsheet: "%s"...\n',A.ExpNo,xlsx_name);

                [H titles]=A.MakeHeaderCell(S);
                D=A.MakeDataCell;

                sheetlist={'Reactiontimes' 'Stimuli' 'Blocknumber' 'Correct' 'Error' 'NoReaction'};

                % Write Column Names
                if ~exist(xlsx_name,'file') % Initialize Headings
                    warning off 'MATLAB:xlswrite:AddSheet' % Cause its annoying
                    for i=1:length(sheetlist)
                        [SUCCESS,MESSAGE]=xlswrite(xlsx_name,[titles sheetlist{i}]',sheetlist{i},'A1');
                        if ~SUCCESS
                            break;
                        end;
                    end
                    warning on 'MATLAB:xlswrite:AddSheet'
                end
                if ~SUCCESS, continue; end

                for i=1:length(sheetlist) % Write Data
                    [SUCCESS,MESSAGE]=xlswrite(xlsx_name,[H D(:,:,1)]',sheetlist{i},sprintf('%s1',xlsColStr(line)));
                    if SUCCESS, disp(['  ' sheetlist{i} ' Written!']); 
                    else 
                        break;
                    end;
                end
                if ~SUCCESS, continue; end
                
                break;
            
            end
            
            disp 'Saved to Spreadsheet.'
        end
        
        function [C titles]=MakeHeaderCell(A,S)
            
            % Numbers of subjects in each
            nos=length(A.SubjNo);
            
            titles={'Experiment' 'Condition' 'Subject' 'Group' 'Position' 'Gender' 'Birthdate'};
            C=cell(nos,length(titles));
            
            for j=1:nos

                Sij=S(A.SubjNo(j));                    
                if ~isequal(Sij.number, A.SubjNo(j))
                    error('Subject number does not match index!'); %#ok<*CPROP,*PROP>
                end
                C(j,:)={A.ExpNo , A.cond , A.SubjNo(j), A.group , A.position(j) , Sij.gender , Sij.birthday};  
            end   
                        
        end
        
        function [C titles]=MakeDataCell(JJ)
            
            titles={'Reactiontimes' 'Stimuli' 'Blocknumber' 'Correct' 'Error' 'NoReaction'};
            C=num2cell(cat(3,JJ.times,JJ.stim,JJ.block,JJ.correct,JJ.error,JJ.noreaction));
            
        end
        
    end
    
    methods % Obselete
        
        function RunRunRun(A)
            %% Configuration
            % Joint Action in a 3 person setting Three choice task for individual
            % condition, Experiment1 "the goal is to averiguate if Simon Effect appears
            % also in a three task condition" Program written by Laura Sergi

            % See Configuration File "JA_Configure"
            [n_block, n_trial, square_width]=JA_Configure;
            
            % Initialize Results Matrix
            [A.times A.stim A.block A.correct A.error A.noreaction]=...
                deal(zeros(length(A.SubjNo),n_trial*n_block));
                
            %--------------------------------------------------------------------------
            %% Initialization
            % This Block should maybe be made a separate file.
            
            start_cogent;
            
            % Welcome slide
                clearpict(13); 
                cgtext(['Willkommen zum Experiment.'],0,100);

            % Fixation-cross slide
                clearpict(2); % clear graphics buffer 2 and set buffer 2 as active following graphics commands are written to buffer 2
                cgpencol(1,1,1); % set drawing color to white
                cgpenwid(1);
                cgdraw(-5, 0, 6, 0); % draws horizontal line of the fixation cross, 'cause 0,0 is the center of the screen
                cgdraw(0, -5, 0, 6); % draws vertical line of the fixation cross, 'cause 0,0 is the center of the screen

            % Instructions slide
                clearpict(12);
                cgtext(['Aufgabenstellung:'],0,0);

                clearpict(11);
                cgpenwid(5);
                cgpencol(1,0,0);
                cgrect(-512+square_width/2+80,250,square_width,square_width);
                cgflip;
                cgtext(['bei rot dr�cke die linke Taste'],-410+square_width/2+400,250);

                cgpenwid(5);
                cgpencol(0,1,0);
                cgrect(-512+square_width/2+80,0,square_width,square_width);
                cgflip;
                cgtext(['bei gr�n dr�cke die mittlere Taste'],-380+square_width/2+400,0);

                cgpenwid(5);
                cgpencol(0,0,1);
                cgrect(-512+square_width/2+80,-250,square_width,square_width);
                cgflip;
                cgtext(['bei blau dr�cke die rechte Taste'],-390+square_width/2+400,-250);

            %Start slide show
                clearpict;
                drawpict(13);
                waitkeydown(inf,[]);

                drawpict(12);
                waitkeydown(inf,[]);

                drawpict(11);
                waitkeydown(inf,[]);

            %% Nested Functions for later use
                
            function [correct err noreaction]=getStatus(status)
               %This is a bit silly, and should be gotten rid of.
               % (replaced with a single symbol indicating whether if was a
               % correct, error, or noreaction)
               switch status
                   case 'correct', correct=1;err=0;noreaction=0;
                   case 'error',    correct=0;err=1;noreaction=0;
                   case 'noreaction',    correct=0;err=0;noreaction=1;
               end
            end

            %% Experiment Loop
            % This will need to be divided up based on condition...
            % Probably best is to make a new object containing all stimulus
            % configuration and instructions, and just run it from this
            % function
            
            for j = 1:n_block % For each block

                % the following text is for the investigator to help him overlook the experiment
                clearpict(1);
                cgtext(['Das ist der ',num2str(j),'. Block'],0,0);
                drawpict(1);
                waitkeydown(inf,[]);

                % Instructions for each block
                drawpict(11);
                waitkeydown(inf,[]);

                n = n_trial;
                RandomList = randperm(n);
                StimulusList = zeros(n,1);

                for i=1:n % Why is this a separate loop from the next one?
                    StimulusList(i)=stimulusN(RandomList(i),n);
                end;

                for i=1:n % For each stimulus round

                    Stimulus = StimulusList(i);
                    
                    
                    drawpict(2); % Fixation cross display
                    wait(1200);
                    clearpict;       
                    stimulusDraw(Stimulus,square_width); % Stimulus draw

                    % get reaction time and write to file
                    clearkeys (); 
                    start_time = drawpict(3); % present graphics buffer 3 and start counting the RTs
                    readkeys (); % get key presses only (no key relases)
                    waitkeydown(3000, []); % present display as long as any of the predefined buttons is pressed, maximum for 3000ms = 3 sec

                    [keyout, end_time, numberofkey] = getkeydown;
                    if numel(keyout)>0, rt = end_time(1) - start_time; % Reaction time
                    else rt=0;
                    end

                    switch Stimulus
                        case {1 2 3}, k=1;
                        case {4 5 6}, k=71;
                        case {7 8 9}, k=12;
                        otherwise, error('Invalid Stimulus: %g',Stimulus);
                    end
                    
                    
                    
                    status=A.Interpret(keyout,k); 
                    if strcmp('status','quit'), stop_cogent; return; end
                    [correct err noreaction]=cellfun(@getStatus,status);             


                    A.times((j-1)*n_trial+i)=rt;
                    A.stim((j-1)*n_trial+i)=Stimulis;
                    A.block(((j-1)*n_trial+i))=j;
                    A.correct(((j-1)*n_trial+i))=correct;
                    A.error(((j-1)*n_trial+i))=err;
                    A.noreaction((j-1)*n_trial+i)=noreaction;

                end;
            end;

            %% Store Results and clean up
            
            
            % Re-arrange by stimulus number
            [~,ix]=sort(A.stim);
            A.times=A.times(ix);
            A.stim=A.stim(ix);
            A.block=A.block(ix);
            A.correct=A.correct(ix);
            A.error=A.error(ix);
            A.noreaction=A.noreaction(ix);
            
            % Stop cogent and exit program
            stop_cogent;

            A.done=true;

            
        end
        
    end
    
    
end

function xlsCol = xlsColStr(colNum)
% Creates Excel Column Letter when the column number entered.
% Useful while writing Matlab data to an excel file's specific location.
% Limited to columns between 1-702 (A-ZZ) created @ September 2009 by ANC
if colNum < 703 && colNum > 0
    if colNum > 26
        k = floor(colNum/26) ;
        if k == colNum/26
            str1 = char(k+63) ;
            str2 = char(26+64) ;
        else
            str1 = char(k+64) ;
            str2 = char((colNum-k*26)+64) ;
        end
        xlsCol = strcat(str1,str2) ;
    else
        xlsCol = char(colNum+64) ;
    end
else
    f = errordlg('Input should be 0 < Column Number < 703 (i.e. A-ZZ) and Scalar', 'ANC');
end
end

function fld=enterfield(FieldName,CriterionFun,CriterionDesc,numeric)
   % Ensures Correct entering of field info
   if ~exist('numeric','var'), numeric=false; end
   good=false;
   while ~good
        fld=input([FieldName ': '],'s');
        if numeric, fld=str2num(fld); end %#ok<ST2NM>
        if CriterionFun(fld)
            good=true;
        else
            disp(['xxx-' CriterionDesc '   Enter again!']);
        end
   end

end