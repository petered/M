classdef AtotheV < handle
    
    properties
        
        
        
        
    end
    
    
    
    methods
        
        function A=AtotheV
            
            
            
        end
        
        function evtRead(A,filename)
            
            [f p]=uigetfile('*.evt');
            filename=[p f];
            
            
            
            
        end
        
        
        
        function import(A)
            % Import from NetStation-exported file
            
            S=uiload('*','Get the file you exported from Netstation');
            
            f=fields(S);
            
            evts=structfun(@iscell,S);
            
            for i=find(f)
                S.(
                
            end
        
        
        end
        
        
    end   
    
    
end