classdef StimCat < handle
% =========================================================================
% StimCat (<a href="matlab:edit('StimCat')">Edit</a>)
% 
% This object corresponds to one round of stimulation of a given type on 
% the cat.  It contains a <a href="matlab:help('SpikeBanhoff')">SpikeBanhoff</a> object, with all the 
% spiking data, and a <a href="matlab:help('FileCat')">FileCat</a> object, from which it can extract stimulus 
% data.  
% 
% % See <a href="matlab:help('ScriptoCats')">ScriptoCats</a> for how this class fits in to the big picture. 
%
% =========================================================================   
    properties
        S;      % SpikeBanhoff Object;
        
        D;      % Stimulus Data Object (to be constructed)
        
        FC=FileCat.empty; % FileCat Object Array listing associated files
        
        name; %
        type; % For easy reference- 'whitenoise','movies','tuning'
    
        
        K; % Kernal Structure as defined in RevCorr
        
    end
       
    
    methods % UI
        
        function GrabCat(A,C_)
            
            
            
            if ~exist('C_','var')
                F=FelineFileFinder; F.Start;
                C_=F.GrabCat;
            end
            
            
            
            S_=SpikeBanhoff;
            S_.GrabCat(C_);
            % D_=StimObj % To be created
            % F_.GrabCat(C);
            
            % If it all works, load into object
            A.FC=C_;
            A.name=C_.catName;
            A.type=C_.type;
           
            A.S=S_;
%             A.D=D_;
                       
            A.K=[];
            
        end
        
        
        
        
    end
    
    methods % Analytical
        
        function [RF ids lags]=RevCorr(A,maxlag,steps,type)
            % Retruns: Cell array RF-indicating receptive field for each
            % cell (3-d matrix: x by y by time)
            % ids: id's of neurons
                       
            
            if ~exist('maxlag','var')||isempty(maxlag), maxlag=0.3; end
            if ~exist('steps','var')||isempty(steps); steps=0.005; end
            if ~exist('type','var')||isempty(steps); type='basic'; end
                        
            [spikes id]=A.FC.loadSpikeInfo;
            [stim edge]=A.FC.StimGrab;
            
            assert(isnumeric(stim),'The Stimulus data appears to be trial-based.  The reverse-correlation method does not yet support this.');
                       
            switch type
                case 'basic'
                    
                case 'absdiff'
                    stim=abs(diff(stim,[],3));
                    edge=edge(2:end);
            end
                
            
            
            ids=unique(id);
            
            meanim=mean(stim,3);
            RF=cell(length(ids),1);
            for i=1:length(unique(id)) 
               [ave stanerr lags]=RevCorr(stim,edge,spikes(id==ids(i)),maxlag,steps);
               RF{i}=(ave-repmat(meanim,[1,1,size(ave,3)]))./stanerr;
            end
            
            
            A.K.RF=RF;
            A.K.ids=ids;
            A.K.lags=lags;
            A.K.type=type;
            
        end
        
        function tx=summary(A)
            
            tx=sprintf('%s:(%gn,%gt)',A.name,size(A.S.T,1),size(A.S.T,2));
            
        end
        
    end
    
    methods % Viewing
        
        function Shoe_RFs(A)
            
            if ~ismember(A.type,{'whitenoise'})
                hW=warndlg('Currently only works for whitenoise data');
                uiwait(hW);
                return;
            end
            
            if isempty(A.K)
                A.RevCorr;
            end
            
            RF=A.K.RF;
            ids=A.K.ids;
            lags=A.K.lags;
            
            colordef black
            figure('name',A.name);
            L=A.FC.cellLegend(ids);
            U=UIlibrary;
            
            if size(RF{1},2)==1 % Bars
                h=nan(1,length(ids));
                for i=1:length(ids)
                    h(i)=subplot(length(ids),1,i);
                    imagesc(lags,[],squeeze(RF{i}));
                    xlabel 'lag (s)'
                    ylabel 'bar position'
                    title(['Receptive field for ' L{i}]);
                    colorbar;
                end               
                U.linkmaxes(h,'c');
                colormap(U.spookymap());
                
            else
                
                h=nan(2,length(ids));
                [x,y,lag]=deal(nan(1,length(ids)));
                for i=1:length(ids)
                    
                    % Plot using TheThirdDimension(TM)
                    [~,locc]=max(RF{i}(:));
                    [y(i) x(i) lag(i)]=ind2sub(size(RF{i}),locc);
                    h(1,i)=subplot(length(ids),2,2*i-1);
                    h(2,i)=subplot(length(ids),2,2*i);
                    limits=[1 size(RF{i},1);1 size(RF{i},2); lags([1 end])];
                    TheThirdDimension(RF{i},limits,[y(i) x(i) lag(i)],h(:,i),'xcolor','w');
                    
                    subplot(h(1,i));
                    xlabel 'x'
                    ylabel 'y'
                    title(['Receptive field for ' L{i}]);
                    
                    subplot(h(2,i));
                    xlabel 'time(s)'
                    ylabel 'Response significance';
                    
                end
                
                U.linkmaxes(h(1,:),'c');
                U.linkmaxes(h(2,:),'y');
                U.spookymap();
                
                
                
            end
            
            
            
        end
        
        
        
        
    end
    
end