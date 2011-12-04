classdef Example < Viewer
    
    properties
        
        
    end
    
    methods
        function A=Example
            A.saveprompt=true;
        end
        
        function StartUp(A)
            % Called after being initialized by A.Start
            
            A.menu4('Options:', {'Function_1','Function_2','Save'});
            
        end
        
        function Function_1(A)
            disp 'Doing Function 1'            
        end
        
        function Function_2(A)
            disp 'Doing Function 2'
        end
        
        
    end
    
    
    
    
end