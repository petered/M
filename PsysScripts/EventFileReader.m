classdef EventFileReader < handle
    
    properties
        
        name;
        date;
        
        E;  % Structure array of events
        
    end
    
    
    
    methods 
        
        function readfile(A,varargin)
            
            [E_ I_]=readEvtFile(varargin{:});
            
            A.name=I_.Title;
            A.date=I_.StartTime;
            A.E=E_;
                        
        end
                    
        function yep=isgroup(A,field,id)
            
            yep=ismember({A.E.(field)},id);
            
        end
            
        function [ix id]=group(A,field)
           % ix is the index identifying the group each event belongs to
           % id is a cell array of names of these events.
                       
           [id,~,ix]=unique(A.E.(field));
           
        end
                        
        function plottimes(A,tarIX,respIX,stimIX,trspIX)
            
            times=[A.E.time];
            
            if islogical(tarIX),tarIX=find(tarIX); end
            if islogical(respIX),respIX=find(respIX); end
            if islogical(stimIX),stimIX=find(stimIX); end
            if islogical(trspIX),trspIX=find(trspIX); end
            
            colordef black
            figure; hold on
            
            plot(times(trspIX),trspIX,'*','color',[.2 .2 .2])
            hL(1)=addlines(times(trspIX),'color',[.2 .2 .2],'LineStyle',':'); 
            
            plot(times(stimIX),stimIX,'*','color',[.2 .2 .2])
            hL(2)=addlines(times(stimIX),'color',[.4 .4 .4]);
            
            plot(times(tarIX),tarIX,'g*')
            hL(3)=addlines(times(tarIX),'g'); 
            
            plot(times(respIX),respIX,'r*')
            hL(4)=addlines(times(respIX),'r');
            
            if ~exist('name','var'), title(sprintf(A.name)); end
            legend (hL,{'TRSP', 'Non-Target Stim', 'Target Stim', 'Responses'})
            xlabel('time(s)');
            
            % Add labels
            labs=arrayfun(@(s)sprintf('%s: A=%g,V=%g',s.code,s.audi,s.visu),A.E,'uniformoutput',false);
            
            %hT=text(0,0,'');
            set(hL,'ButtonDownFcn',@(e,s)rollover);    
            function rollover
                
                P=get(gca,'currentpoint');
                x=P(1);
                y=P(1,2);
                [~,ix]=min(abs(times-x));
                
                text(x,y,labs{ix},'rotation',90);                
            end
            
            
        end
        
        % Copy properties of one set of indeces to another
        function propmove(A,ix1,ix2,fields)
            % The specific point of this is to copy attributes of the TRSP
            % class to the preceding Snd+ class indeces.
            
            
            
        end
        
        
        function repairtimes(A,code)
            
            [baddies,gaps,mdt]=A.findbadtimes(code);
            
            EE=A.E;
            fprintf('Fixing %g misplaced events\n',numel(baddies));
            for i=1:length(baddies)
                EE(baddies(i)).time=EE(gaps(i)).time-mdt;                
            end
            [~,ix]=sort([EE.time]);
            A.E=EE(ix);
            A.findbadtimes(code);
                        
        end
        
        
        % Fix the time-jumping problem
        function [baddies,gappers,mdt]=findbadtimes(A,code)
            % This fixes the problem of these weird off-time Snd+ signals.
            
            ix=find(A.isgroup('code',code));
            times=[A.E(ix).time];
            
            dt=[inf diff(times)];        
            mdt=median(dt);
            
            baddies=dt==0;            
            gappers=abs((dt-2*mdt))/mdt<.02;
            
            % Bad ones before a gap can be fixed.
            baddies=find(baddies);
            gappers=find(gappers);
            
            tit=sprintf('Found %g repeated %s events, %g gaps',numel(baddies),code,nnz(gappers));
            figure;
            hold on;
            hL=plot(ix,times,'*','color',[.5 .5 .5]);
            plot(ix(baddies),times(baddies),'r*');
            plot(ix(gappers),times(gappers),'g*');
            legend ({'Events' 'Bad' 'gaps' 'Location' 'Best'});
            title(tit);
                        
            baddies=ix(baddies);
            gappers=ix(gappers);
            
            
            % Add labels
            labs=arrayfun(@(s)sprintf('%s: A=%g,V=%g',s.code,s.audi,s.visu),A.E,'uniformoutput',false);
            set(hL,'ButtonDownFcn',@(e,s)rollover);    
            function rollover
                P=get(gca,'currentpoint');
                x=P(1);
                y=P(1,2);
                [~,ix]=min(abs(times-x));
                text(x,y,labs{ix});                
            end
            
        end
        
    end
    
    methods (Static)
        
        % Quick Start
        function A=go
            A=EventFileReader;
            A.readfile;
            
        end
        
        % Get RT's given stim-times, response times
        function [RT correct]=getRTs(tStim,tResp,timeout)
            % In:
            % Tstim is a vector of stim times
            % Tresp is a vector of response times
            % Timeout is either
            % - A scalar indicating how long to wait for response
            % - A 2-el vector indicating start/end times of wait
            %
            % Out:
            % RT is the reaction-time to each stim.. nan for no reaction.
            % correct is a boolean indicating if there was a reaction.
            %
            
            if numel(timeout)==2, timein=timeout(1); timeout=timeout(2); 
            else timein=0;
            end
            
            [RT correct]=deal(nan(size(tStim)));
            for i=1:length(tStim)
                theone=tResp(find(tResp>tStim(i)+timein & tResp<tStim(i)+timeout,1));
                if isempty(theone)
                    correct(i)=false;
                else
                    correct(i)=true;
                    RT(i)=theone-tStim(i);
                end  
            end
            
        end
        
        % Find set of indeces in ix1 that precede each index of ix2
        function ix=findlastix(ix1,ix2)
            % ix 1 is a list of events times/indeces
            % ix 2 is another list of events times/indeces
            % this function returns the values of ix1 that came most
            % recently before the ix2 events.
            %
            % ix will have the same length as ix2, unless there is more
            % than one element of ix1 between two subsequent ix2 events, in
            % which case ix will have more.
            %
            % EG:
            % ix1=[1 3 5 7 9]; ix2=[3.2 6.5]; ==> ix=[3 5]
            
            if islogical(ix1), ix1=find(ix1); ixlog=ix1; relog=true;
            else relog=false; end
            if islogical(ix2), ix2=find(ix2); end
            
            [n bin]=histc(ix2,ix1);
            
            if any(n>1), disp 'WARNING: multiple events found in same bin'; end
            
            ix=ix1(bin);
            
            if relog
                ixlog=false(size(ixlog));
                ixlog(ix)=true;
                ix=ixlog;
            end
            
        end
        
        
    end
    
end