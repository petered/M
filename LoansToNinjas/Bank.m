classdef Bank < DataBaseItem
    
    properties
        
        M;                  % List of mortgages owned
        
        MT;                     % List of available mortgage types.  
        
        Mlen=20;    % Available mortgage terms
        
        H;      % List of owned houses
        
        liquid; % Liquid assets
                
        payThresh=1.2;
        
        W;
        
    end
    
    methods
        
        function x(A,cash)
            % Exchange money
            
            A.liquid=A.liquid+cash;
            
            
        end
        
        function Mlist=grantMortgage(A,H,O)
            % Decide whether to grant a mortgage to a given homeowner.
            % Return a list of mortgages for which the Homeowner is
            % approved.  If the list is empty: re-JECTED!
            
            Mlist=Mortgage.empty;
            for i=1:length(A.MT)
                for j=1:length(A.Mlen)
                    M_=A.MT(i).realize(H,A.Mlen(i));

                    if M_.meetsCriteria(O)
                        Mlist=[Mlist M_]; %#ok<AGROW>
                    end
                end
            end
            
        end
        
        function closeMortgage(A)
            
        end
        
        function suggestMortgage(A)
        
            
        end
        
    end
    
end