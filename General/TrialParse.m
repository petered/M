function [trialbounds ix]=TrialParse(x,varargin)
% Define trial boundaries based on photodiode signal.
% [bounds ticks]=TrialParse(x);
%
% x is a timeseries vector indicating some sort of trial structure.
%
% trialbounds is an Nx2 vector defining the start-stop times of each trial.
%   The intervals will all be of equal length.
%
% ix is the list of peaks found, put into a cell array of size N
%
%
% TODO:
% Currently it's a little vulnerable to spurious spikes in the signal.
% Might be a good idea to remove bits that don't seem to match with the
% rest of the data.
%
% But it works for now.  Will fix as needed.

for i=1:2:length(varargin)
   switch varargin{1}
       case 'thresh'
           thresh=varargin{i+1};
           
           
   end   
    
end

if ~exist('thresh','var'), thresh=mean(x)+std(x); end

    minpeakdiv=4;           % Fraction of fundamental period over which to accept adjacent peaks
    RatioThresh=5;          % Threshold Ratio between medean inter-peak interval and inter-trial interval
    acceptancerange=0.8;    % Range of inter-trial ratio over which to accept trials.

    per=ceil(FunPer(x)/minpeakdiv);

    [ix height]=peakseek(x,per,thresh);
    
    % Filter out bad peaks based on height.
    ix=heightfilter(ix,height);
                
    
    ix=[1 ix length(x)];
    
    
    dix=diff(ix);
    
    
    CutSt=find(abs(dix)>RatioThresh*median(dix));

    edges=ix(CutSt+1)';    
    
    % Filter for "Funny" trials
    space=diff(edges(1:end-1));
    funny=space<median(space)*acceptancerange;
    if ~isempty(funny);
       fprintf('Trial(s) [%s] found to be "funny".  Deleting.\n',num2str(find(funny)));
       edges(funny)=[];
       CutSt(funny)=[];
    end
    edges=edges-min((ix(CutSt+1)-ix(CutSt)))/2;
    
    cix=min(diff(edges));
    
    trialbounds=[edges(1:end-1) edges(1:end-1)+cix];
     
    if nargout>1
        
        d=diff(CutSt);
        ix=ix(CutSt(1)+1:CutSt(end));
        ix=mat2cell(ix,1,d);
        
%         ix=ix(1:end-1);
    end
    
    
end

function ix=heightfilter(ix,height)

    % Filter out bad peaks based on height.
    [his hts]=hist(height,20);     % Histogram of the heights
    [tp p]=peakseek(his,1,2);  % Find local maxima of histogram
    [~, ixm]=max(p);            % If more than one, remove lower group
    if ixm>1, bound=mean([hts(tp(ixm-1)),hts(tp(ixm))]); ix=ix(height>bound); end
%     if ixm<length(tp), bound=mean([hts(tp(ixm)),hts(tp(ixm+1))]); ix=ix(height>bound); end

end