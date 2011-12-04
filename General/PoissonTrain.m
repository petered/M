function T=PoissonTrain(rate,time,invCF)
    % Spits out a Poisson Train.  
    % Possible optimization (for speed).  Make frac dependent on rate/time.
    % 
    % rate is the figring rate.
    % time is the time span
    % invCF (optional) is the inverse of the cumulative distribution
    %   function.  It can be either a function or a vector.
    % If a function: it should be an inverse Cumulative Distribution.  That
    %   is, positive, monotonic, <=1.
    % If a vector: rate shoule also be a vector.  invCF is then the
    %   probability of each rate
    
    
    T=[];
    frac=1.2;
    Tstart=0;
    
    if ~exist('invCF','var')
        invCF=@(rate,N)-1/rate*log(rand(1,N));
        expRate=rate;
    else
        if isvector(invCF)
            if sum(invCF)~=1, 
                disp('When invCF is a vecotr, first row must sum to 1!  We''ll do if for you');
                invCF=invCF(:)/sum(invCF);
            end
            C=cumsum(invCF);
            expRate=mean(rate(:).*invCF);
            invCF=@(rate,N)1./arrayfun(@(ran)rate(find(ran<C,1)),rand(1,N));
            
        else
            expRate=rate;        
        end
    end
    
    
    
    while true
%         RV= -rate^-1*log(rand(1,ceil(frac*rate*time)));
        RV=invCF(rate,ceil(frac*expRate*time));
        RV(1)=RV(1)+Tstart;

        T=[T cumsum(RV)]; %#ok<AGROW>

        if T(end)>time
            T=T(1:find(T<time,1,'last'));
            break;
        else
            Tstart=T(end);
            frac=0.2;
        end

    end

end