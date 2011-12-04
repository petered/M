function [T un]=SplitSpikes(spikes,id,bounds, equaltrials)
% T=SplitSpikes(spikes,id,bounds);
%
% Takes a sorted array of spike times, splits it into a cell array based on
% the onset times in boundaries.  
%
% INPUTS
%
% "Spikes" is a vector of spike times.
%
% "id" is a vector of neuron id's for each spike.  (id should be the same
%   length as spikes).  By convention, id's of 0 are considered unknown and
%   ignored.
%
% "bounds" is a vector of trial onset times.  Though it's not essential,
%   these should all be about the same distance apart.  The last trial
%   (whose endpoint is undefined) will be assumed to be the median of the 
%   length of all the other trials.
%
% "equaltrials" is an optional boolean (default false) that sets all
%   trial-lengths to be the minimum separation in bounds.  
%
% OUTPUTS
%
% "T" will be an NxT cell array, where N is number of neurons, and T is
%   number of trials.
%
% "un" is a vector of the id numbers corresponding to each row of cell
%   array T.
%
% Peter
% oconnorp _at_ ethz _dot_ ch

%% Make inputs all nice and pretty

% By default, keep spikes with ID of zero
if ~exist('equaltrials','var'), equaltrials=false; end

% Test if trials are defined by start/end times, or just a series of starts.
if ~isempty(bounds) && ~isvector(bounds)
    assert(size(bounds,1)==2,'If "bounds" is not a vector, it must be a 2xN matrix');
    doublebound=true;
else
    doublebound=false;
end

% Columnize everything
spikes=spikes(:);
id=id(:);
bounds=bounds(:);


if numel(id)~=numel(spikes)
    error('"id" and "spikes" should be the same length!');
end

if ~exist('id','var') || isempty(id)
    id=ones(size(spikes)); % Assume one neuron
end

if ~exist('bounds','var') || isempty(bounds)
    bounds=[spikes(1) Inf]; % Assume one trial
else
    % disp 'Assuming last trial is the median length of the others!'
    bounds=[bounds; bounds(end)+median(diff(bounds))];
end

un=unique(id);

if ~issorted(spikes)
   error('Spikes aren''t sorted.  This is bad!'); 
end

% This feature was stupid, should be done outside of this function
% % if removezeros && any(un==0) 
%    display 'Warning: Spikes with id 0 were found.  Ignoring these.'
%    un=un(un~=0);
% end

st=find(spikes>bounds(1),1);
en=find(spikes<bounds(end),1,'last');

if st>1 || en<length(spikes)
   fprintf ('Warning: %g%% of spikes fall outside the defined trial boundaries, and will be dropped\n',(1-(en-st+1)/(length(spikes)))*100);
   spikes=spikes(st:en);
   id=id(st:en);
end

%% Get 'er done

T=cell(nnz(un),length(bounds)-1);
bCell=num2cell(bounds(1:end-1));
for i=1:length(un)

    % Indeces of spikes in this list
    ixN=id==un(i);
    
    % Vector of spike counts in each bin
    nSpike=histc(spikes(ixN),bounds); 

    % Split them up and subtract start times
    C=mat2cell(spikes(ixN),nSpike(1:end-1),1);
    if equaltrials
        
    else
        T(i,:)=cellfun(@(x,t)x-t,C,bCell,'UniformOutput',false);
    end

end

if doublebound
    T=T(:,1:2:end);
end

% Chop the trials if needed.  Yes it could be done more efficiently, but
% seriously the time it takes to parse out this comment is probably the
% same as the normal time difference, and this is nice and clean
if equaltrials
    minbound=min(diff(bounds));
    fprintf ('All trials truncated to minimum trial length of %gs',minbound);
    T=cellfun(@(x)x(x<minbounf),T,'UniformOutput',false);    
end


end