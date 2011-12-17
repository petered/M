classdef World < DataBaseItem
    
    properties
        
        % References
        
        PW=World.empty;             % Link to past worlds
        H=House.empty;              % Array of houses
        M=Mortgage.empty;           % Array of Mortgages
        O=HomeOwner.empty;          % Array of homeowners.
        B=Bank.empty;               % Array of banks
        MT=MortgageType.empty;      % Array of mortgage types
        HforSale;                   % List of houses for sale
        
        
        % Global Figures        
        fedInterest;                % Federal Bank Interest Rate    
        houseIndex;                 % Housing index
        houseIndexHistory;          % History of housing index
        rent;                       % Yep, same rent for everyone.
        
        priceMem;
        
        t=1;                        % Time step        
        
        pJobLoss;                   % Probability of losing a job
        pJobGain;                   % Probability of getting a job    
        jobProb;        
        
        pSell;
        
        thisMonthsSales;
        
        actions=struct;
        
        
    end
    
    methods 
        
        
        function registerSale(A,H)
            % Register the sale of house H
            
            A.thisMonthsSales=[A.thisMonthsSales H.price/H.worth];
                        
            
        end
        
        function reportAction(A,action)
                        
            if ~isfield(A.actions,action)
                A.actions.(action)=0;
            end
            
            A.actions.(action)=A.actions.(action)+1;
            
        end
        
        function set.pJobLoss(A,pJobLoss)
            A.pJobLoss=pJobLoss;
            A.jobProb=[]; %#ok<*MCSUP>
        end
        
        function set.pJobGain(A,pJobGain)
            A.pJobGain=pJobGain;
            A.jobProb=[];
        end
        
        function js=jobSecurity(A,employed,nsteps)
            % Returns a vector representing your probability of having a
            % job from 1:nsteps steps in the future
            %
            % Employed is a boolean indicating whether you're employed now
            
            
            if nsteps>length(A.jobProb)
                X=[1-A.pJobLoss  A.pJobGain; A.pJobLoss 1-A.pJobGain];
                nojob=nan(2,nsteps);    nojob(:,1)=[0;1];
                havejob=nan(2,nsteps);  havejob(:,1)=[1;0];
                for i=2:nsteps
                    havejob(:,i)=X*havejob(:,i-1);
                    nojob(:,i)=X*nojob(:,i-1);
                end                
                A.jobProb=[havejob(1,:);nojob(1,:)];
            end
            
            js=A.jobProb(2-employed,:);
            
        end
        
        function HforSale=get.HforSale(A)
            if isempty(A.H),HforSale=[]; return; end
            HforSale=A.H([A.H.forSale]);
            
        end
        
        function Stats=collectStats(A,Stats)
            % Given a structure array of function handles, return a
            % structure array of values that come from running these
            % functions with the world as an argument
            
            fld=fields(Stats);
            for i=1:length(fld)
                Stats.(fld{i})=Stats.(fld{i})(A);                
            end
        end
        
        function updateHousingIndex(A)
            A.houseIndex=mean(A.thisMonthsSales);
            
            if isnan(A.houseIndex), A.houseIndex=A.houseIndexHistory(end-1); end
            A.houseIndexHistory(end+1)=A.houseIndex;
        end
    end
    
    
    methods % Iteration methods
        
       
        function reset(A)
            
           A.thisMonthsSales=[];
           A.actions=struct('keep',0,'default',0,'sell',0,'refinance',0,'rent',0,'buy',0,'homeless',0);
           
            
        end
        
        function update(A)
            
            A.t=A.t+1;
            
            A.reset;
            
            % Update initals
%             houses4sale=[A.H.forSale];
%             A.houseIndex=mean([A.H(houses4sale).price]./[A.H(houses4sale).worth]);
%             if isnan(A.houseIndex), A.houseIndex=A.houseIndexHistory(end-1); end
            
            
            % Run HomeOwners in random order.
            O_=permrand(A.O); inc=.1; pass=inc;
            fprintf('  Running %g HomeOwners: ',length(O_))
            for i=1:length(A.O)
                O_(i).update;
                if i>pass*length(O_)
                    fprintf('%g%%..',pass*100);
                    pass=pass+inc;
                end
            end
            disp 'Done';
            
            % Come up with this years housing index
            A.updateHousingIndex;
            
        end
        
        
    end 
    
    methods % Initialization Methods
        
        function inTheBeginning(A)
            
            A.H.distribute('W',A);
            A.M.distribute('W',A);
            A.O.distribute('W',A);
            A.B.distribute('W',A);
            A.MT.distribute('W',A);
            
%             vacants=A.H(arrayfun(@(x)isempty(x.Owner),A.H));
            
            % Give vacant homes randomly to banks
%             vacants.link('Owner',A.B,'H',true,1,true);
            
            
%             [A.H.W A.M.W A.O.W A.B.W A.MT.W]=deal(A);
            
        end
        
        
        
    end
    
    
    
end