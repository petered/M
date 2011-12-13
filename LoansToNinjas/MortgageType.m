classdef MortgageType < handle
    
    properties
        
        % Properties of mortgage type
        adjustable;     % Boolean: 
                        % true: Adjustable interest rate: tied to fed
                        % false: Fixed interest rate.  Decided on at start
        
        rate;           % if adjustable=true : monthly interest rate 
                        % if adjustable=false: additional interest rate (to federal) 
        
        teaser;         % Special interest rate (just for adjustables) 
                        % offered in initial years of mortgage.  
        
        B;              % Bank
        
        down;           % Fraction of house cost required as downpayment
        
        incomeBuffer;   % Buffer defining minimum income
        
    end
    
    methods
        
        function granted=evaluate(A,H,O)
            
            granted=O.cash>down*H.price;
            
            
        end
        
        
        function M=realize(A,H,time)
            % Initialize a real Mortgage from a mortgage type
                        
            if A.adjustable
                [schP schC]=A.makeAdjustableSchedule(time,A.teaser,A.rate+A.W.fedRate,principal);
            else
                [schP schC]=A.makeFixedSchedule(time,A.teaser,A.rate+A.W.fedRate,principal);
            end
            
            M=Mortgage;
            M.principal=principal;      % House cost minus downpayment
            M.adjustable=A.adjustable;
            M.type=A.type;
            M.scheduleP=schP;
            M.scheduleC=schC;
            M.H=H;
            M.MT=A;
            M.B=A.B;
            M.downPayment=A.H.price*A.down;
            
        end
        
        
        
        
    end
    
    
end