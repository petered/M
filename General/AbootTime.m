function [c boots lags]=AbootTime(x,y,maxlags,nBoots)
%%
% So it can be tricky to figure out if two timeseries are non-obviously
% correlated, because each signal often has internal statistical
% correlations.  Result is that these signals can display large cross
% correlations, in spite of not actually having any connection.
%
% This function takes the signals and correlates them, but also generates
% new signals, taken form randomly permuting the old signals and filtering
% them to have the same frequency-domain structure.  You can then compare
% the real correlation with the series of Bootstrapped (fake) correlations
% to see if the real one's actually signif.
% 
% Things to consider: This isn't technically bootstrapping, since we're
% sampling without replacement.  Would sampling with replacement be better?
%  Are you a statistical theorist?  You tell me.
%
% Is it enough to just remix one signal at a time (doing that now), or
% should both be done?
% 
% author
% Peter O'Connor
% oconnorp .at. ethz dawt ch

if ~exist('maxlags','var'), maxlags=[]; end
if ~exist('nBoots','var'), nBoots=20; end

[c lags]=xcov(x,y,maxlags,'coeff');

% Randomizing function
remix=@(sig)ifft(fft(sig/norm(sig)).*fft(sig(randperm(end))));

if ~isempty(maxlags), boots=nan(2*maxlags+1,nBoots);
else boots=nan(length(x)+length(y)-1,nBoots);
end
    
fprintf('%g boots, bootstrapping ',nBoots);
for i=1:nBoots
    fprintf('%g..',i);
    if rand>0.5,    boots(:,i)=xcov(x,remix(y),maxlags,'coeff');
    else            boots(:,i)=xcov(remix(x),y,maxlags,'coeff');
    end
end
fprintf('Done\n');


% For Testing, uncomment this code:
colordef black
plot(lags,c,'g'); hold on; plot(lags,boots,'color',[.5 .5 .5]);
hold off;


end