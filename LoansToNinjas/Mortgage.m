classdef Mortgage < DataBaseItem
% This class serves both to define a mortgage, and a class of mortgages.  
    
    properties
                
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
        
        downPayment;    % Initial downpayment on mortgage
        
        principal;      % Amount outstanding on loan
                
        scheduleP;      % Vector representing the payment schedule on 
                        % principal for each period.  Must sum to original 
                        % prinipal on house (at period=1) for an amortizing
                        % loan.
                        
        scheduleC;      % Vector representing the total payment schedule.  
                        % For adjustable rate mortgages, this is only an
                        % estimate after the length of "teaser".
                        
        startPeriod;
        
        
        % Dependent
        period;         % Period (month) of mortgage term
                        
        duration;       % Duration of mortgage
                        
        % Links
        H;              % House
              
        O;              % Owner (linked through house)
        
        W;              % The world.
        
        B;              % Bank (linked through Mortgage type)
        
        MT;             % Mortgage Type
        
        
    end
    
    methods
        
        function duration=get.duration(A)
            duration=length(A.scheduleP);
        end
        
        function period=get.period(A)
            period=A.W.t-A.startPeriod+1;
        end
        
        function B=get.B(A)
            B=A.MT.B;
        end
        
        function remove(A)
           
            A.B.M(A.B.M==A)=[];
            A.H.M=[];
            
        end
        
        function r=LTV(A)
            % Loan-to-value ratio.

            r=A.principal./A.H.value;
            
        end
        
        function O=get.O(A)
            
            O=A.H.Owner;
            
        end
        
        function yep=meetsCriteria(A,O)
            % See if a homeowner meets the mortgage criteria
            yep= O.cash > A.downPayment && O.salary > A.MT.incomeBuffer*A.scheduleC(1);
            
        end
        
        function payment=payment(A)
            % Payment for this month
            
            if A.adjustable
                if A.period<=length(A.teaser), ir=A.teaser(A.period);
                else ir=A.W.fedInterest+A.rate;
                end
            else
                ir=A.rate;
            end
            interest=ir*A.principal;    
            
            payment=interest+A.scheduleP(A.period);
            
        end
        
        function [c p]=predictedPayments(A,nsteps)
            % Predicted payments for nsteps in the future, INCLUDING this
            % one
            %
            % p is the principal remaining after nsteps
            %
            % If adjustable, the prediction uses present interest rates.
            
            remaining=length(A.scheduleP)-A.period+1; % Remaining time in mortgage
%             mend=min(length(A.scheduleP),nsteps+A.period-1);
            
            endChunk=zeros(1,nsteps-remaining);
            
            if A.adjustable
                
                
                
                remainingTeaser=length(A.teaser)-A.period;
                teaserChunk=A.teaser(A.period:min(end,A.period+nsteps));
                
                currRate=A.W.fedInterest+A.rate;
                normalChunk=repmat(currRate,[1 min(remaining-length(teaserChunk),nsteps)]);
                
                ir=[teaserChunk normalChunk];
                
%                 ir=[A.teaser(end-remainingTeaser:min(end,A.period+nsteps)) repmat(currRate,[1 mend-A.period-max(remainingTeaser,0)])];
                
%                 pri=A.scheduleP(end-remaining:end);
%                 pri=A.scheduleP(A.period:mend);
                              
            else
                
                ir=repmat(A.rate,[1 min(remaining,nsteps)]);
                
                
                
%                 ir=repmat(A.rate,[1 mend-A.period+1]);
                
%                 ir=
%                 c=[A.scheduleC(A.period+1:end) endportion];
            end
            
            pri=A.scheduleP(A.period:min(end,A.period+nsteps-1));
            
            int=(A.principal-pri).*ir;
            c=[pri+int endChunk];
            
            if nargout>1
                p=A.principal-sum(pri);
            end
            
        end

        function makePayment(A)
            % Make the montly mortgage payment
            payment=A.payment;
            
            A.O.x(-payment);
            A.B.x(payment);
            
            A.principal=A.principal-payment;
            
            if A.period==A.duration
                assert(A.principal<.01,'Something''s wrong: The mortgage has supposedly run its course but there''s still %g left on the principal');
                A.remove;                
            end
            
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