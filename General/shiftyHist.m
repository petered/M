function [counts lagles]=shiftyHist(edges,spikes,maxlag,lagstep)
% This is handy for reverse correlation.  It takes 
% 
% Inputs (optionals in brackets)
% edges:        vector of stimulus change times
% spikes:       vector of spike times
% maxlag:       maximum shift to the spike times
% (lagstep):    amount to step the lag counter (default maxlag/50)


if ~exist('lagstep','var')||isempty(lagstep), lagstep=maxlag/50; end

lagles=-maxlag:lagstep:maxlag;


counts=nan(length(lagles),length(edges)-1);

fprintf('Computing shiftyHist...0%%..');
progperc=.1;

for i=1:length(lagles)
    
    hhh=histc(spikes+lagles(i),edges);
    counts(i,:)=hhh(1:end-1);
    
    if i/length(lagles)>progperc
        fprintf('%g%%..',progperc*100);
        progperc=progperc+.1;
    end
    
end
fprintf('Done.\n');

end