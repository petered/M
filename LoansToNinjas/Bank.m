classdef Bank < handle
    
    properties
        
        M;                  % List of mortgages owned
        
        MT;                     % List of available mortgage types.  
        
        Mlens=[15 20 30]*12;    % Available mortgage terms
        
        H;      % List of owned houses
        
        liquid; % Liquid assets
        
    end
    
    methods
        
        function x(A,cash)
            % Exchange money
            
            A.liquid=A.liquid+cash;
            
            
        end
        
        function M=grantMortgage(A,H,O)
            % Decide whether to grant a mortgage to a given homeowner.
            % Return a list of mortgages for which the Homeowner is
            % approved.  If the list is empty: re-JECTED!
            
            
        end
        
        function closeMortgage(A)
            
        end
        
        function suggestMortgage(A)
        
            
        end
        
    end
    
end