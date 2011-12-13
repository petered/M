classdef World < handle
    
    properties
        
        PW;             % Link to past worlds
        
        H;              % Array of houses
        
        M;              % Array of Mortgages
        
        O;              % Array of homeowners.
        
        B;              % Array of banks
        
        fedInterest;    
        
        houseIndex;     % Housing index
        
        
        % Quick references to above
        HforSale;   % List of houses for sale
        
        t;  % Time step
        
        
        pJobLoss;   % Probability of losing a job
        pJobGain;   % Probability of getting a job    
        
    end
    
    methods 
       
        function HforSale=get.HforSale(A)           
            
            HforSale=A.H([A.H.forSale]);
            
        end
        
        
    end
    
    
    methods % Iteration methods
        
        function update(A)
            
            
            
        end
        
        
    end 
    
    methods % Initialization Methods
        
        function initHouses(A,mean,spread,N)
            
                       
            
            
        end
        
        
        
    end
    
    
    
end