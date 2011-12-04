function p=sigpredict(varargin)
% Given a kernel, predict the signal.
%
% Usage:
% p=sigpredict(events,edges,K,lags);
% p=sigpredict(sig,K,lags);
%
% Inputs
% events    - a list of event times
% edges     - a list of stimulus-frame transition times
% K         - the kernel, where first dimension is time, second is whatever. 
% lags      - the lags reprenting the kernel lags.  length(lags)=size(K,1) 
%
% Outputs
% p         - a prediction of the stimulus.  size(length(edges-1) x size(K,2) 
%             This matrix is basically just made by adding the kernel
%             wherever there's an event, into the bins defined in edges.


if nargin==3
   p=sigpred(varargin{:});
    
elseif nargin==4
   p=eventpred(varargin{:});
    
else
    error('should be 3 or 4 inputs');
end






end


function p=eventpred(events,edges,K,lags)

if ~issorted(events), error('events aren''t sorted'); end


if length(lags)~=size(K,1);
    error('Length lags (%g) should equal the 1st dim of your kernel, (%g)',length(lags), size(K,1));    
end


% Matrix of times, where timelist(i,j) is the time of the jth lag from the ith event.
timeslist=repmat(events(:),[1 length(lags)])+repmat(lags(:)',[length(events),1]);

% Counts is now a length(edges-1) x length(lags) matrix of counts for each lag
counts=histc(timeslist,edges);

p=zeros(length(edges)-1,size(K,2));
for i=1:length(lags)
    ja=find(counts(:,i));
    
    % Add all instances of that kernel-lag to that frame
    p(ja,:)=p(ja,:)+repmat(K(i,:),[length(ja) 1]).*repmat(counts(ja,i),1,size(K,2));


end

end

function p=sigpred(sig,K,lags)




end