classdef HomeOwner < DataBaseItem
    
    properties
        
        % Basic
        cash;               % Cash in hand
        salary;             % Salary minus non-home expenses
        discount;           % Rate of discount (per period)
        memory;             % Decay rate of memory (per period)
        nHousesToSearch;    % Number of houses to search
        wantHouse;          % Boolean, describing whether homeowner is looking for a house
              
        buyHassle;          % Cost of hassle of buying a house
        sellHassle;         % Cost of hassle of selling
        refinanceHassle;    % Cost of hassle of refinancing
        
        
        % Linking        
        H;              % Array of houses
        
        M;              % List of Mortgages (linked through house)
                        % CAUTION: M will usually, but not necessarily, be
                        % the same length as H.  M can be shorter if the
                        % homowner owns homes that have been paid off.
        
        W;              % Reference to world
        
        B;              % Banks in contact
        
        
        
        
        
    end
    
    methods
        
        function M=get.M(A)
           
            M=A.H.M;
            
        end
        
        function success=houseSearch(A)
            
            H_=randsample(A.W.HforSale,A.nHousesToSearch);
            
            % Sort by worth, descending
            [~,ix]=sort([H_.worth],'descend');
            H_=H_(ix);
                        
            % Search from the most valuable house on down.
            for h=1:length(H_)
                M_=A.financeSearch(H_(h));
                
                if isempty(M_) % If no loans available, move on down the list
                    if h<length(H_) % If all houses already searched.  Give up
                        continue;
                    else            % Else lower your standards.
                        success=false;
                        return;
                    end
                else            % If loan is availble, buy
                    A.buy(H_(h),M_);
                    success=true;
                    return;
                end
            end
            
        end
        
        function M_=financeSearch(A,H)
            % For a list of houses H, find the best mortgage available from
            % all banks in contact.
            
            M_=cell(1,length(A.B));
            for b=1:length(A.B)
                M_{b}=A.B(b).grantMortgage(A,H);
            end
            
            if all(cellfun(@isempty,M_));   % If no finance available, return empty
                M_=[];
                return;
            end
            
            Mcost=cellfun(@(m)A.costCalc(m),Mlist);
            
            [~,morgIX]=min(Mcost);
            
            M_=Mlist(morgIX);
            
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
                
        function buy(A,H,M,S)
            % Buy a house H from a seller S using a mortgage M
            
            price=H.price;  % Home price
            S.x(price);     % Seller gets $$$
            S.payoffMortgage(H.M);  % Seller pays off old mortgage
            M.B.x(-price);  % Bank pays money (note.. this cancels out with last step if bank is seller)
            
            % Transfer Payments
            downPayment=price*M.MT.down;
            A.x(-downPayment);              % Buyer pays downpayment
            A.M.B.x(downPayment);           % Bank gets downpayment
                        
            % Transfer Ownerships
            S.H(S.H==H)=[]; % Seller gives up keys
            A.H=[A.H H];    % HomeOwner now owns new home
            H.M=M;          % Mortgage attached to home
            M.B=[M.B M];    % Bank now has new mortgage
            H.Owner=A;      % Owner of home is HomeOwner
            H.forSale=false;% Because it's sold!
             
        end
        
        function pay(A)             
            % Make the monthly mortgage payments
            
            for i=1:length(A.M)
                payment=A.M(i).payment;
                A.cash=A.cash-payment;
                A.M(i).B.liquid= A.M(i).B.liquid+payment;
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
            % (same as buying a house from yourself, just with a new
            % mortgage)
            
            A.buy(A,H,M,A);
            
            
            
        end
        
        function action=toKeepOrNotToKeep(A,H)
            % Decide whether to sell, stay, or default on house.
            
            if H.forSale
                action='sell';
                return;
            end
            
            if H.payment>H.cash % No choice
                action='default';
                return;
            end
            
            % Apart from that, there's a choice.
            
            
            
        end
        
        function toBuyOrNotToBuy(A)
            % Decide whether to buy a house.
            % Note.. this must depend on: 
            %  present emoloyment, cash
            %  housing trend
            %  
            
            % Basically: 
            % For
            % - Expected house profit
            % - House Desire
            % 
            % Against
            % - Rent Cost
            % - Hassle Factor;
            % 
            
            
            
            
        end
        
        
        function update(A)
            
            
            
            
            
        end
        
        
        
        
        
        
    end
        
    
    
    
end