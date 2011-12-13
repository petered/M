classdef House < handle
    
    properties
        
        
        
        % Basic
        price;       
        worth; % Relative value
        forSale=false;
                
        % Derived (see get methods)
        value;  % worth*(housing index)
        
        % Linking
        M;      % Mortgage        
        Owner;  % Owner.  Can be a Bank or a HomeOwner
        W;      % World
        
    end
    
    
    methods
       
        function value=get.value(A) % Estimated Value
                       
            value=A.worth*A.W.houseIndex;
            
        end
        
        function price=get.price(A)
            
            price=A.worth*A.W.houseIndex; % TODO: this is too simple, need to factor in selling desperation
            
        end
        
    end
    
end