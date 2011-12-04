function [ave, stanerr, lags]=RevCorr(imset,edges,spikes,maxlag,lagstep)
% Reverse Correlation
%
% Inputs
% Imset:    (nY x nX x nImages) matrix of images shown (in order)
% edges:    vector of stimulus transition times (length must be size(ImSet,3)+1) 
% spikes:   vector of spike times.
% maxlags:  max time for shifting spike-times
% (lagstep):time between steps of lags
%
% Outputs
% ave:      (nY x nX x nLags) matrix of mean image at time T
% stanerr:  (nY x nX x nLags) standard error.  Compare this to mean
%            difference from mean stimulation.

if length(edges)~=size(imset,3)+1
    error('Length of edges should be 1 greater than size(imset,3).  See help for why');
end

if ~exist('lagstep','var'), lagstep=[]; end


    [counts,lags]=shiftyHist(edges,spikes,maxlag,lagstep);

    si=size(imset);
    
    % Stats on imset(used in computing cr)
% meani=mean(imset,3);
    
    
    % Could mayyyybe be done without for loop but whatever
    [ave stanerr]=deal(nan(si(1),si(2),length(lags)));
    fprintf('Computing Revcorr lag (%g in total): ',length(lags))
    
    for i=1:length(lags)
        
        countvec=reshape(counts(i,:),1,1,[]);
        countsum=sum(countvec);
        
        ImCount=imset.*repmat(countvec,si(1),si(2));
        ave(:,:,i)=sum(ImCount,3)/countsum;
        
        
        
        stanerr(:,:,i)=sqrt(1./((countsum-1)*countsum) *sum((ImCount-repmat(ave(:,:,i),[1,1,si(3)])).^2,3));
        
%         tstat(:,:,i)=(ave(:,:,i)-meani)./stanerr;
        % I think... this still needs to be double checked.
        fprintf('%g..',i);
    end
    disp Done

end