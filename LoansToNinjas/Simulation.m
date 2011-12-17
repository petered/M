classdef Simulation < handle
    
    properties
        
        W=World.empty;      % Vector of worlds
        
        t;      % Current time-step
        
%         Wo;     % Initial world
        
        nSteps; % Number of Time steps to run (includes initial)
        
        Wt;     % Most Recent World
        
        showLive=true;   % Show results live
        
        Stats=struct;
        S=struct;
        Ac=struct;
        
        hFs;     % Stat Figure
        hFa;     % Action figure
    end
        
    methods
                
        function run(A)
            
            assert(~isempty(A.W),'The "World" property, "Wo", has not been initialized.');
            
%             A.W=A.Wo;
            A.S=A.Stats;
            A.S(1)=A.W.collectStats(A.Stats);
            A.Ac=[];
            

            fprintf('Starting Simulation\n');
            for i=2:A.nSteps;
                fprintf('Step %g: \n',i-1);
                
%                 fprintf('  Copying World...');
% %                 A.W(i)=A.W(i-1).copy;       % Make a copy of the previous world;
%                 A.W(i).t=i;
                disp Done;
                
                A.W.update;               % Do the stuff
                
                A.S(i)=A.W.collectStats(A.Stats);
                
                fld=fields(A.W.actions);
                for f=1:length(fld), 
                    A.Ac(i).(fld{f})=A.W.actions.(fld{f}); 
                end
                
                if A.showLive
                    A.displayStats;  
                    A.displayActions;
                end
            end
            
        end
        
        function displayStats(A)
                        
            if isempty(A.hFs) || ~ishghandle(A.hFs);
                A.hFs=figure('position',[680 87 548 891]);
                U=UIlibrary;
                h=U.buttons({'Pause'});
                set(h,'callback',@(e,s)pausePlay);
            end
            N=length(fields(A.Stats));
            nR=ceil(N/2);
            nC=ceil(N/nR);
            
            paused=false;
            function pausePlay
                if paused
                    uiresume;
                    paused=false;
                    set(h,'string','Pause');
                else
                    paused=true;
                    set(h,'string','Play');
                    keyboard;
                end
                
            end
            
            fld=fields(A.S);
            figure(A.hFs);
%             clf;
            for i=1:length(fld)
                subplot(nR,nC,i);
                plot([A.S.(fld{i})]);
                ylabel(fld{i});
            end
            drawnow;
            
        end
        
        function displayActions(A)
            
            if isempty(A.hFa) || ~ishghandle(A.hFa);
                A.hFa=figure;
            end
            
            figure(A.hFa);
            fld=fields(A.Ac);
            clf;
            hold all;
            for i=1:length(fld)
                plot([A.Ac.(fld{i})]);
            end
            fld{strcmp(fld,'default')}='defauIt';
            legend(fld);            
        end
        
        function Wt=get.Wt(A)
            Wt=A.W(A.t);
        end
        
        function runLink(A) %#ok<MANU>
            fprintf('Click <a href="matlab:%s.run">HERE</a> to run simulation\n',inputname(1));
        end
    end
    
end