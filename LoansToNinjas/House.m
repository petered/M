classdef House < DataBaseItem
    
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
                       
            if isempty(A.W), value=[]; return; end
%             value=A.worth*A.W.houseIndex;

% 
%             tail=min(ceil(A.W.priceMem*3),length(A.W.houseIndexHistory));
%             w=exp((-tail+1:0)/A.W.priceMem);
%             value=sum(w.*A.W.houseIndexHistory(end-tail+1:end))/sum(w);
             value=A.worth*mean(A.W.houseIndexHistory(end-A.W.priceMem:end));
        end
        
    end
    
    methods (Static)
        
        function H=build(worths)
                        
            S=struct('worth',{worths});

            H_=House;
            H=H_.init(S,length(worths));
                           
        end
        
        
    end
    
end