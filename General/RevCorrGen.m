function [ave, stanerr, lags]=RevCorrGen(imset,signal,maxlag)
% Reverse Correlation
%
% Inputs
% Imset:    nFrames x nDimensions series of stimuli
% signal:   Signal to be predicted
% maxlags:  max time for shifting spike-times
% (lagstep):time between steps of lags
%
% Outputs
% ave:      (nLags x nD) matrix of mean image at time T
% stanerr:  (nY x nX x nLags) standard error.  Compare this to mean
%            difference from mean stimulation.

    si=size(imset);
    if ~isvector(signal), error('signal should be a vector, asshole'); end
    
    
    
    % Stats on imset(used in computing cr)
% meani=mean(imset,3);
    
lags=-maxlag:maxlag;    

    % Could mayyyybe be done without for loop but whatever
    [ave stanerr]=deal(nan(length(lags),si(2)));
    fprintf('Computing Revcorr lag (%g in total): ',length(lags))
    for i=1:length(lags)
        
        if lags(i) < 0
            countvec=[zeros(-lags(i),1); signal(1:end+lags(i))];
        else
            countvec=[signal(lags(i)+1:end); zeros(lags(i),1)];      
        end        
        
        countsum=sum(countvec);
        
        ImCount=imset.*repmat(countvec,1,si(2));
        ave(i,:)=sum(ImCount,1)/countsum;
              
        
%         stanerr(i,:)=sqrt(1./((countsum-1)*countsum) *sum((ImCount-repmat(ave(i,:),[si(1),1])).^2,3));
        
%         tstat(:,:,i)=(ave(:,:,i)-meani)./stanerr;
        % I think... this still needs to be double checked.
        fprintf('%g..',i);
    end
    disp Done
    
    ave=ave-repmat(mean(imset),size(ave,1),1);
    

end