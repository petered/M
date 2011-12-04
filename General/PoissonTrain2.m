function T=PoissonTrain2(rate,time)
% T=PoissonTrain2(rate,time)
%
% Spits out something close to a rate-varying Poisson-Train.  Only catch is
% that spike times are descretized into bins, where bin width is the end
% time ("time") over the length of the rate vector.  There's a warning if
% these bins are too small to accurately model a Poisson Process.
%
% "rate" is the expected rate, which can vary with time (eg: in spikes/s).
%   Negative rate is the same as zero rate.
% "time" is the total time (eg. in seconds)
% "T" is the spike times (eg. in seconds, if you used the above units)
%

    
    dt=time/length(rate);
    
    if max(rate(ceil(rand(1,100))))*dt > 0.1
        disp(['Warning...Your maximum rate is high enough that it''s '... 
            'reasonably likely that multiple spikes are being thrown into '...
            'the same time bin and therefore only counted once.  This '...
            'function suggests increasing the resultion of your '...
            'rate signal, which will shrink the time bins.']);
    end
    
    T=(find(rand(size(rate))<rate*dt)-1)*dt;
    

end