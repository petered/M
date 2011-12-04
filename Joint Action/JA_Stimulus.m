classdef JA_Stimulus < handle
% This object just exists to contain all the stimulus instructions and
% configuration files.
    properties
       
        cond;           % Condition: 1,2 or 3;
        
        n_block;        % Number of blocks to run
        n_trial;        % Number of trials per block
        square_width;   % Width of the squares
        
    end
    
    methods % General Functions
        
        function Configure(S) % Configuration File
            
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

            %--------------------------------------------------------------
            % Save required properties
            S.square_width=square_width; %#ok<*PROP>
            S.n_trial=n_trial;
            S.n_block=n_block;
        end

        function Start_Screen(S) % Welcome Screen 
                        
            % Load required properties
            square_width=S.square_width;
            
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

                clearpict(11);
                cgpenwid(5);
                cgpencol(1,0,0);
                cgrect(-512+square_width/2+80,250,square_width,square_width);
                cgflip;
                cgtext('bei rot dr�cke die linke Taste',-410+square_width/2+400,250);

                cgpenwid(5);
                cgpencol(0,1,0);
                cgrect(-512+square_width/2+80,0,square_width,square_width);
                cgflip;
                cgtext('bei gr�n dr�cke die mittlere Taste',-380+square_width/2+400,0);

                cgpenwid(5);
                cgpencol(0,0,1);
                cgrect(-512+square_width/2+80,-250,square_width,square_width);
                cgflip;
                cgtext('bei blau dr�cke die rechte Taste',-390+square_width/2+400,-250);

            %Start slide show
                clearpict;
                drawpict(13);
                waitkeydown(inf,[]);

                drawpict(12);
                waitkeydown(inf,[]);

                drawpict(11);
                waitkeydown(inf,[]);

            
        end
        
        function varargout=Stim_Cycle(S,varargin)   % Play in stimulation loop
           
            switch S.cond
                case 1
                    varargout=C1_Stim_Cycle(S,varargin{:});
                case 2
                    varargout=C2_Stim_Cycle(S,varargin{:});
                case 3
                    varargout=C3_Stim_Cycle(S,varargin{:});
            end
            
        end 
        
        function varargout=Block_Start(S,varargin)  % Play at Block-Start 
           
            switch S.cond
                case 1
                    varargout=C1_Block_Start(S,varargin{:});
                case 2
                    varargout=C2_Block_Start(S,varargin{:});
                case 3
                    varargout=C3_Block_Start(S,varargin{:});
            end
            
        end 
        
    end
    
    methods % Condition-Specific Functions
        
        function C1_Block_Start(S,blockno) % Condition 1: Start-Block Screen
            
            % the following text is for the investigator to help him overlook the experiment
            clearpict(1);
            cgtext(['Das ist der ',num2str(blockno),'. Block'],0,0);
            drawpict(1);
            waitkeydown(inf,[]);

            % Instructions for each block
            drawpict(11);
            waitkeydown(inf,[]);

            
        end
        
        function [k keyout rt]=C1_Stim_Cycle(S,Stimulus) % Condition 1: Stimulus cycle
            
            square_width=S.square_width;
            
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

                    
            
        end
        
    end
    
    methods (Static)
    
        function start_cogent
            start_cogent;
        end
        
        function stop_cogent
            stop_cogent;            
        end
            
    end
    
    
end