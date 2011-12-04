function [F V M W]=RovingFanos(T,window,conds)
% On retrospect, this was a huge waste of time, but hey it works.
%
% T is a cell vector of sorted event(read:spike) time vectors.  Each cell
%       represents a trial.
% window is a time window.
% conds is a list of conditions over which to take the Fano-Factor.
%
% F is a vecor of fano-factors
% N is an array the same size as F of the mean number of spikes in each




if ~exist('conds','var'), conds=ones(1,size(T,2)); end

T=T(:); T=cellfun(@(x)x(:),T,'uniformoutput',false);
cond=conds(:);

[sV tV nTrials]=icantthinkofaname(T,cond);
% cV{i} contains sorted concatenation of spike times in condition i
% tV{i} contains corresponding trial indeces

[V M W]=cellfun(@(svec,tvec,nT)RedRover(svec,tvec,window,nT),sV,tV,num2cell(nTrials)','uniformoutput',false);

F=cellfun(@(v,m)v./m,V,M,'uniformoutput',false);

end

function [Vi Ni Ti]=RedRover(svec,tvec,window,nTrials)
    % svec is the spike-times vector (should be sorted!)
    % tvec is the trial-ids vector
    %
    % Fi is the Fano-Factor of each interval
    % Ni is the mean-spike count
    % Ti is the window-position (middle) at each count

    if isempty(svec), Vi=[]; Ni=[]; Ti=[]; return; end
    
    % trash! isis!
    [~,~,tvec]=unique(tvec);
    isis=diff(svec);
    
    % Initialize that biatch
    ixfirst=1;
    ixlast=find(svec<window,1,'last');
    if isempty(ixlast), ixlast=1; end
    
    finalfirst=find(svec<svec(end)-window,1,'last');
    active=1;
    
%     first=svec(1);
%     last=svec(1)+window;
    
    totlength=length(svec)+finalfirst-ixlast-1;
    [Ni Vi Ti]=deal(nan(1,totlength));
    
    for i=1:totlength
        
        % Find counts for each trial
        slots=zeros(1,nTrials);
        trialsinwin=tvec(ixfirst:ixlast);
        counts=accumarray(trialsinwin,ones(size(trialsinwin)));
        slots(1:length(counts))=counts;
        
        % Get Stats;
        Ni(i)=mean(slots);
        Vi(i)=var(slots);
        Ti(i)=svec(ixfirst)+window/2;
        
        % See if it's working right
%         if exist('hL','var'), delete(hL(ishandle(hL))); 
%         end
%         switch active
%             case 1;  hL=addlines(svec(ixfirst)+[0 window],'k','linewidth',2);
%             case 2;  hL=addlines(svec(ixlast)-[window 0],'k','linewidth',2);
%             
%         end
        
        % Figure out which to increment
        switch active
            case 1 % ixfirst is on an event
                [~,inc]=min([isis(ixfirst),svec(ixlast+1)-(svec(ixfirst)+window)]);
            case 2 % ixlast is on an event
                [~,inc]=min([svec(ixfirst+1)-(svec(ixlast)-window),isis(ixlast)]);
        end
        
        % Increment
        switch inc
            case 1, ixfirst=ixfirst+1; active=1;
            case 2, ixlast=ixlast+1; active=2;
        end
                
                
    end
    
    


end

function [sV tV nTrials]=icantthinkofaname(T,cond)
    % Pretty obvious what this one does.
    [un nTrials]=uniquecounts(cond);
    [sV tV]=deal(cell(1,length(un)));
    trials=cellfun(@(c,x)repmat(c,size(x)),num2cell(1:length(cond))',T,'uniformoutput',false);
    for i=1:length(un)
        svec=cat(1,T{cond==un(i)});
        tvec=cat(1,trials{cond==un(i)});
        [svec,ix]=sort(svec);
        tvec=tvec(ix);
        sV{i}=svec;
        tV{i}=tvec;
    end
end



function [d count ix]=uniquecounts(w)

[d w2d d2w]=unique(w);
[~,ix]=unique(sort(d2w));
count=diff([0;ix]);

end
