function [events directions score]=signalscan(X, validscore)
% X is matrix, nSamples x nChannels
% Events is a cell array of event indeces (for each channel)
% Directions is a cell array of booleans indicating up or down event.

% Not this is somewhat vulnerable to salt and pepper noise.

if numel(X)==length(X), X=X(:); end
if ~exist('validscore','var'), validscore=20; end


mx=max(X,[],1);
mn=min(X,[],1);
div=(mx+mn)/2;

C=mat2cell(X,size(X,1),ones(1,size(X,2)));

ix=cellfun(@(x,d)x>d,C,num2cell(div),'UniformOutput',false);

V=cellfun(@(X,ix)std(X(ix)),C,ix);

score=(mx-mn)./V;
valid=( score > validscore);

[events directions]=cellfun(@eventtimes,ix,num2cell(valid),'UniformOutput',false);


end

function [e dir]=eventtimes(ix,valid)

    if ~valid, e=[]; dir=[]; return; end

    d=diff(ix);
    
    e=find(d);
    
    dir=d(e)>0;

    e=e+1;
end