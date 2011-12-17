classdef HomeOwner < DataBaseItem
    
    properties
        
        % Basic
        cash;               % Cash in hand
        salary;             % Salary minus non-home expenses
        hasJob;             % Got a job?
        discount;           % Rate of discount (per period)
        memory;             % Decay rate of memory (per period)
        nHousesToSearch;    % Number of houses to search
        wantHouse;          % Boolean, describing whether homeowner is looking for a house
              
        americanDream;      % How much is having a house worth?
        sellHassle;         % Cost of hassle of selling
        refinanceHassle;    % Cost of hassle of refinancing
        
        
        LTVthresh;          % Loan-to-value threshold
        
        % Linking        
        H;              % Array of houses
        
        M;              % List of Mortgages (linked through house)
                        % CAUTION: M will usually, but not necessarily, be
                        % the same length as H.  M can be shorter if the
                        % homowner owns homes that have been paid off.
        
        W;              % Reference to world
        
        B;              % Banks in contact
        
        foresight;      % How many periods to look ahead when making decisitons
        
        panicHorizon;   % How many periods to look into the future when deciding whether it's worth it to sell/refinance
        
        saleMarkup; % Fraction of markup to add when first selling
        salePanic;  % Fraction to take off sale price with each turn unsold
        
        tag;        % Tag to identify a homeowner
        
        lastAction;
    end
    
    methods
        
        function update(A)
            
            % Employment
            if A.hasJob
                A.getPaid;
                A.hasJob=rand>A.W.pJobLoss;
            else
                A.hasJob=rand<A.W.pJobGain;
            end
                
            % Housing
            if isempty(A.H)   % If you have a house
                action=A.toBuyorNotToBuy;    
            else
                action=A.toKeepOrNotToKeep(A.H);
            end
            
            A.lastAction=action;
            A.W.reportAction(action);
            
            
            
        end
                
        function action=toBuyorNotToBuy(A)
            
            H_=randsample(A.W.HforSale,min(A.nHousesToSearch,length(A.W.HforSale)));
            if isempty(H_) % Not a single house in the entire world is for sale
                action='rent';
                return;
            end
            
            % Sort by worth, descending
            [~,ix]=sort([H_.worth],'descend');
            H_=H_(ix);
                        
            % Search from the most valuable house on down.
            
            
            % Go through each house and find a net cost for each;
            NetValue=nan(1,length(H_));
            Mlist(1,length(H_))=Mortgage;
            for h=1:length(H_)
                
                HouseValue=A.valuate(H_(h));                                 
                [M_ MortgageCost]=A.financeSearch(H_(h));               % Find the best-value mortgage for this house
                if ~isempty(M_)
                    NetValue(h)=HouseValue+A.americanDream*H_(h).worth-MortgageCost+A.valuate(A.W.rent);
                    Mlist(h)=M_;
                end
            end
            
            % Find best value.
            ixg=find(~isnan(NetValue) & NetValue>0);
            [~,ix]=max(NetValue(ixg));
            ix=ixg(ix);
            if isempty(ix)  % If no luck, try again
                if A.cash>A.W.rent;
                    action='rent';
                    A.x(-A.W.rent);
                else
                    action='homeless';
                end                
            else            % If you got one, buy it
                action='buy';
                A.buy(H_(ix),Mlist(ix));
                
            end
            
%                 if isempty(M_) % If no loans available, move on down the list
%                     if h<length(H_) % If all houses already searched.  Give up
%                         NetCost(h)=-Inf;
%                         continue;
%                     else            % Else lower your standards.
%                         success=false;
%                         return;
%                     end
%                 else            % If loan is availble, buy
%                     
%                     
% 
%                     A.buy(H_(h),M_);
%                     success=true;
%                     return;
%                 end
            
            
            
            
        end
        
        function action=toKeepOrNotToKeep(A,H)
            % Decide whether to sell, stay, or default on house.
            
            % Decisions.  
            if isempty(A.H.M)&&~H.forSale % If your mortgage is all paid off, and your'e 
                action='keep';
            elseif ~isempty(A.H.M) && (H.M.payment>A.cash || A.H.M.LTV>A.LTVthresh), % If the loan to value ratio is too damn high
                % If you can't pay, or the Loan-To-Calue ratio is too high, default!
                action='default';
                
            elseif H.forSale        % If it's already for sale, keep it for sale, but lower price cause you're getting desperate
                action='sell';
            else 
                c=A.forecastCash(A.panicHorizon);  % Forcase cash flow up to panicHorizon
                if all(c>0),        % If you can make the payments...
                    action='keep';
                else                % If you're going to run out of money within the panicHorizon
                    M_=A.financeSearch(H);
                    if ~isempty(M_) && all(M_.principal-H.M.principal+c)>0   % If you can by refiancing % TODO; is this right?
                       action='refinance';
                    else                                    % If you still can't
                       action='sell';
                    end
                end
            end
                        
            if strcmp(action,'keep') && rand<A.W.pSell   % There's still the spontanious selling probability
                action='sell';
            end            
            
%             fprintf('%s..',action);
            
            % Now ACT!
            switch action 
                case 'keep'
                    A.payMortgage;
                case 'sell'
                    A.payMortgage;
                    if ~isempty(A.M)
                        minsaleprice=H.M.principal-A.cash+.01;
                    else 
                        minsaleprice=-Inf;
                    end
                    A.putForSale(H,minsaleprice);
                    

%                     A.payMortgage;
%                     A.putForSale(H);
%                 case 'keepForSale'
%                     minsaleprice=H.M.principal-A.cash;
%                     
%                     if ~isempty(H.M)
%                         minsaleprice=H.M.principal-A.cash;
%                         A.payMortgage;
%                         H.price=max(H.price*(1-A.salePanic),H.M.principal);
%                     else
%                         H.price=H.price*(1-A.salePanic);
%                     end
%                     action='sell';
                case 'refinance'
                    A.payMortgage;
                    A.refinance(H,M_);  % M_ is the new mortgage found above
                case 'default'
                    A.default(H.M);
                    H.forSale=true;
            end
            
            
        end
        
        function [liquid equity]=forecastCash(A,steps)
            % Estimate how much cash you gonna have.  This estimate get
            % made after you get paid before your mortgage bill.
            
%             in=A.salary*(0:steps-1);
            in=cumsum(A.salaryEstimate(steps));
            
            out=0;
            for i=1:length(A.M)
                out=out+A.M.predictedPayments(A.panicHorizon);
            end
            liquid=in-out+A.cash;
            
            if nargout>1
                equity=0;
                for i=1:length(A.H)
                    equity=equity+predictValue(A.W.houseIndexHistory,A.memory,steps);
                end
            end
        end
        
        function s=salaryEstimate(A,nsteps)
            % Gguess your salary for the next nsteps, based on your current
            % salary, current employement, and hiring/firing rates.
            
            s=A.W.jobSecurity(A.hasJob,nsteps)*A.salary; 
            
        end
                
        function [M_ cost]=financeSearch(A,H)
            % For a list of houses H, find the best mortgage available from
            % all banks in contact.
            
            M_=cell(1,length(A.B));
            for b=1:length(A.B)
                M_{b}=A.B(b).grantMortgage(H,A);
            end
            
            if all(cellfun(@isempty,M_));   % If no finance available, return empty
                M_=[];
                cost=nan;
                return;
            end
            
%             Mcost=cellfun(@(m)A.costCalc(m),Mlist);
            Mlist=cat(2,M_{:});

            v=A.valuate(Mlist);
            
            mcost=-v;   % Cost of mortgage
            
            [cost,morgIX]=min(mcost);
            
            M_=Mlist(morgIX);
                        
        end
                   
        function v=valuate(A,Obj)
            % Return the (discounted) value of this object (house or 
            % mortgage) up to the forsight point.
            
            v=nan(size(Obj));
            
            switch class(Obj)
                case 'House'
                    % For houses, predict the future value at the forsight
                    % time, discount it back to the present.
                    
                    for i=1:length(Obj)
                        H_=Obj(i);
                        pred=predictValue(A.W.houseIndexHistory,A.memory,A.foresight,A.discount)*H_.worth;
                        investmentValue=pred(end);
                        v(i)=investmentValue;
                    end
                    
                case 'Mortgage'
                    % For mortgages, account for all payments, then treat
                    % the remaining principal as a lump sum at the end.
                    
                    for i=1:length(Obj)
                        M_=Obj(i);
                        [payments finalPrincipal]=M_.predictedPayments(A.foresight);
                        payments(1)=M_.downPayment;
                        payments(end)=payments(end)+finalPrincipal;
                        v(i)=-adjustedValue(payments,A.discount);
                    end
                    
                case 'double'   % Evaluate the cose of some repeated payment, like rent
                    if isscalar(Obj)
                        payments=repmat(Obj,[1 A.foresight]);
                    else
                        payments=Obj;
                    end
                    v=adjustedValue(payments,A.discount);
                    
            end              
            
        end
             
        function C=costCalc(A,M)
            % Calculate the cost of a mortgage.
            
            C=nan(size(M));
            for i=1:length(M)
                C(i)=adjustedCost(M.scheduleC,A.discount);
            end
            
        end
                
        function payoffMortgage(A,M)
           % Pay the remaining principal on a mortgage. 
           % This can happen after:
           % - Refinancing
           % - Selling
           % - Making last payment (in this case this function pays off the (zero) principal, and deletes the mortgage
           
           if isempty(M) % Rockin! No mortage to pay off!
               return;
           end
           
           assert(isequal((M.O),A),'You''re trying to pay someone else''s mortgage?');
           assert(A.cash>M.principal,'Not enough cash to pay this mortgage');
           
           remaining=M.principal;
           
           % Transfer monay
           A.x(-remaining);         % Person pays remaining
           M.B.x(remaining);        % Bank receives remaining
           
           M.remove();              % Remove Mortgage
           
            
        end
        
        function x(A,cash)
            assert(A.cash+cash>0,'This transaction would result in negative cash!');
            
            A.cash=A.cash+cash;
            
        end
                
        function buy(A,H,M)
            % Buy a house H from a seller S using a mortgage M
            
            S=H.Owner;
            
            % Old Owner gets MONAY
            price=H.price;  % Home price
            S.x(price);     % Seller gets $$$
            if isa(S,'HomeOwner'),S.payoffMortgage(H.M); end % Seller pays off old mortgage
            M.B.x(-price);  % Bank pays money (note.. this cancels out with last step if bank is seller)
            
            % Transfer Payments
            downPayment=price*M.MT.down;
            A.x(-downPayment);              % Buyer pays downpayment
            M.B.x(downPayment);             % Bank gets downpayment
                        
            % Transfer Ownerships
            S.H(S.H==H)=[]; % Seller gives up keys
            A.H=[A.H H];    % HomeOwner now owns new home
            H.M=M;          % Mortgage attached to home
            M.B=[M.B.M M];    % Bank now has new mortgage
            H.Owner=A;      % Owner of home is HomeOwner
            H.forSale=false;% Because it's sold!
             
            % Tell the world
            A.W.registerSale(H);
        end
        
        
        function payRent(A)
            
            A.x(-A.W.rent);
            
        end
        
        
        function payMortgage(A)             
            % Make the monthly mortgage payments
           
            for i=1:length(A.M)
%                 payment=A.M(i).payment;
%                 A.cash=A.cash-payment;
%                 A.M(i).B.liquid= A.M(i).B.liquid+payment;
                A.M(i).makePayment;
            end            
            assert(A.cash>0,'HomeOwner has negative cash.  Shouldn''t be possible');
        end
        
        function default(A,M)
            % Default on a mortgage
            
            A.H(A.H==M.H)=[];       % Owner walks out
            M.B.H=[M.B.H M.H];      % Bank now owns house
            M.H.Owner=M.B;          % House Owner is bank
            M.remove();             % Mortgage ceases to exist
            
        end
        
        function refinance(A,H,M)
            % Refinance a house with a new mortgage
            %
            % (same as buying a house from yourself, just with a new mortgage)
            % TODO: this is true, right?
            
            A.buy(H,M);
            
        end
        
        function putForSale(A,H,minprice)
           
            if ~exist('minprice','var'), minprice=-Inf; end
                
            if H.forSale
                H.price=max(H.price*(1-A.salePanic),minprice);     
            else
                H.forSale=true;
                H.price=max((1+A.saleMarkup)*A.H.value,minprice);      
            end
            
        end
        
        function getPaid(A)
            A.cash=A.cash+A.salary;            
        end
        
        function M=get.M(A)
           
            if isempty(A.H),M=Mortgage.empty; return; end
            M=A.H.M;
            
        end
        
                
    end
        
    
    
    
end