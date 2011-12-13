classdef Simulation < handle
    
    properties
        
        W;      % Vector of worlds
        
        t;      % Current time-step
        
        Wo;     % Initial world
        
        nSteps; % Number of Time steps to run (includes initial)
        
        Wt;     % Most Recent World
        
    end
    
    
    methods
                
        function run(A)
            
            assert(~isempty(W0),'The "World" property, "Wo", has not been initialized.');
            
            A.W(1)=A.Wo;
            A.W=[];
            
            for i=2:A.nSteps;
                
                A.W(i)=A.W(i-1).copy;       % Make a copy of the previous world;
                
                A.W(i).update;               % Do the stuff
                
            end
            
        end
        
        function Wt=get.Wt(A)
            Wt=A.W(A.t);
        end
    end
    
end