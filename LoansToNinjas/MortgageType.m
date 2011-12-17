classdef MortgageType < DataBaseItem
    
    properties
        
        % Properties of mortgage type
        adjustable;     % Boolean: 
                        % true: Adjustable interest rate: tied to fed
                        % false: Fixed interest rate.  Decided on at start
        
        ratePremium;    % Addition to standard interest rate
        
        teaser;         % Special interest rate (just for adjustables) 
                        % offered in initial years of mortgage.  
        
        B;              % Bank
        
        down;           % Fraction of house cost required as downpayment
        
        incomeBuffer;   % Buffer defining minimum income relative to downpayment.
        
        W;
    end
    
    methods
        
        function granted=evaluate(A,H,O)
            
            granted=O.cash>A.down*H.price;
            
            
        end
        
        
        function M=realize(A,H,time)
            % Initialize a real Mortgage from a mortgage type
                                    
            
            M=Mortgage;
            M.downPayment=H.price*A.down;
            M.principal=H.price-M.downPayment;
            
            if A.adjustable
                [schP schC]=M.makeAdjustableSchedule(time,A.ratePremium+A.W.fedInterest,A.teaser,M.principal);
                M.rate=A.ratePremium;
            else
                [schP schC]=M.makeFixedSchedule(time,A.ratePremium+A.W.fedInterest,M.principal);
                M.rate=A.ratePremium+A.W.fedInterest;
            end
            
            M.startPeriod=A.W.t;
            M.adjustable=A.adjustable;
            M.scheduleP=schP;
            M.scheduleC=schC;
            M.H=H;
            M.MT=A;
            M.B=A.B;
            M.W=A.W;
            
        end
        
        
        
        
        
    end
    
    
end