classdef Mortgage < handle
% This class serves both to define a mortgage, and a class of mortgages.  
    
    properties
        
        id;             % ID indexing mortgage
        
%         active=true;    % Whether the mortgage is active.
        
        % Properties of mortgage type
        adjustable;     % Boolean: 
                        % true: Adjustable interest rate: tied to fed
                        % false: Fixed interest rate.  Decided on at start
        
        rate;           % if adjustable=true : monthly interest rate 
                        % if adjustable=false: additional interest rate (to
                        % federal), if teaser is expired
        
        teaser;         % Special interest rate (just for adjustables) 
                        % offered in initial years of mortgage.  
        
        B;              % Bank
        
        MT;             % Mortgage Type
        
        % Properties of specific mortgage
        
        downPayment;    % Initial downpayment on mortgage
        
        principal;      % Amount outstanding on loan
                
        scheduleP;      % Vector representing the payment schedule on 
                        % principal for each period.  Must sum to original 
                        % prinipal on house (at period=1) for an amortizing
                        % loan.
                        
        scheduleC;      % Vector representing the total payment schedule.  
                        % For adjustable rate mortgages, this is only an
                        % estimate after the length of "teaser".
                        
                        
        period=1;       % Period (month) of mortgage term
                        

                        
        H;              % House
                
        
        O;              % Owner (linked through house)
        
        W;              % The world.
        
    end
    
    methods
        
        function remove(A)
           
            A.B.M(A.B.M==A)=[];
            A.H.M=[];
            
        end
        
        function r=LTV(A)
            % Loan-to-value ratio.

            r=A.principal./A.H.estValue;
            
        end
        
        function O=get.O(A)
            
            O=A.H.O;
            
        end
        
        
        function payment=payment(A)
            % Payment for this month
            
            if A.adjustable
                interest=(A.W.fedInterest+A.rate)*A.principal+A.schedule(A.period);
            else
                interest=A.rate*A.principal;                
            end
            
            payment=interest+A.schedule(A.period);
            
        end
        
        

        
        
    end 
    
    methods (Static)
                
        
        
        function [p c]=makeFixedSchedule(paymentTime,rate,principal)
            % Make a payment schedule that will pay off the principal in
            % paymentTime periods with an interest rate of "rate", such
            % that, after the final payment, the outstanding principal will
            % be zero.
            %
            % returns "p", a vector of monthly payments to the principal
            % and "c" the total monthly payment at the given rate
            
%             p=rate./(1-(1+rate).^(-paymentTime))*principal;
            
            ip=(1+rate).^(0:paymentTime);
            
%             p=principal*(ip-(ip-1).*ip(end)/(ip(end)-1));
            
%             ip=principal*(diff(ip)-rat

            p=principal*rate*ip(1:end-1)*(1/(ip(end)-1));

            c=repmat(principal*rate/(1-1/ip(end)),size(p));
            
            % Note that, not by coincidence, the principal payment for a
            % given month will be the total payment minus the interest
            % outstanding on the principal.
        end
        
        function [p c]=makeAdjustableSchedule(paymentTime,estimatedRate,teaserRate,principal)
           % p is the principal payment per term.  Calculated using the
           % estimated interest rate.  
           %
           % c in this case is an estimated payment schedule.  It is only
           % certain for the length of the teaserRate.
           %
           % teaserRate is a vector of the length of the promotional
           % period, where each element is the "teaser" interest rate for
           % that period.  In any normal case, all elements of the vector
           % will be the same.
            
           p=Mortgage.makeFixedSchedule(paymentTime,estimatedRate,principal);
           
           c=(principal-cumsum([0 p(1:end-1)])).*[teaserRate , repmat(estimatedRate,1,paymentTime-length(teaserRate))]+p;
            
        end
        
        
        
    end
    
    
end