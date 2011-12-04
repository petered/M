% =========================================================================
% Ministers Cat (<a href="matlab:edit('MinistersCat')">Edit</a>)
% 
% These objects represent a singe electrode penetration in the cat
% experiments.  Typically they will contain several sub-experiments in
% which different stimuli (movies/tuning/whitenoise) are played.  This
% sub-experiments are contained in the <a href="matlab:edit('StimCat')">StimCat</a> objects in array E. 
% 
% When the object is loaded, all the StimCat objects are "aligned" (see
% method "alignCells", such that A.E(i).S.T(k,:) refers to a set of trials
% from the same cell as A.E(j).S.T(k,:).
%
% See <a href="matlab:help('ScriptoCats')">ScriptoCats</a> for how this class fits in to the big picture. 
%
% =========================================================================


classdef MinistersCat < Viewer
    
    properties
        
        name; % Name ID'ing cat/penetration #
        
        E=StimCat.empty;  % Array of StimExp performed on that cat/penetration
        
        notes;
        
        
        ids; 
        
    end
    
    properties % Shortcuts, for convenience
        
        % Convenience Properties
        S; % Struct Array of E.S objects
        D; % Struct Array of E.D objects
        
        whi; % Handle to whitenoise StimCat
        tun; % Handle to tuning StimCat
        mov; % Handle to movies StimCat
        
        
    end
    
    properties (Hidden=true)
        
%         selCat; % Selected Cat.  Prompts user to select which cat we're talking about.
        
        
    end
    
    methods % Data I/O
        
        function success=GrabCat(A,sel)
            % sel indicates the number of the cat to select.  It's
            % optional, and you can pick one if you don't enter it
            %
            % success indicates whether the number in sel exists.  It's
            % useful if you're calling this method in a loop to accumulate
            % results for different cats.
            
            success=false;
            [F IDs map]=A.GrabList;
            
            if ~exist('sel','var')
                [sel,ok] = listdlg('ListString',IDs,'PromptString','Select an experiment set','SelectionMode','single');
                if ~ok, return; end
            end
            
            ix=find(map==sel);
            
            A.name=IDs{sel};
            for i=1:length(ix)
               SC=StimCat;
               SC.GrabCat(F.E(ix(i)));  
               A.E(i)=SC;
%                switch SC.type
%                    case 'whitenoise'
%                        A.whi=SC;
%                    case 'tuning'
%                        A.tun=SC;
%                    case 'movies'
%                        A.mov=SC;
%                    otherwise
%                        fprintf('That''s strange, we''ve never heard of this experiment type "%s"\n',SC.type);
%                end
            end
            
            success=true;
        end
        
    end
    
    methods % get/set and dependencies and stuff
        
        function selCat=selCat(A)
             list={A.E.name};
            
            k=0;
            
            function setix(val)
               k=val;
               delete(h);
            end
            
            h=uicontextmenu;
            cellfun(@(nm,i)uimenu(h,'label',nm,'callback',@(e,s)setix(i)),list,num2cell(1:length(list)));
            set(h,'Visible','on');
%            
            waitfor(h,'Visible','off');
            
            pause(.05); % Needed to ensure that setix runs before k is tested.
            
            if k==0
                error('MATLAB:getselector:noselection','No Cat selected.  Actually this is ok, it was just mode convienient to use and exception here.  Sorry about the red!');
            else
                selCat=A.E(k);
            end
            
        end
        
        function set.E(A,E)
            A.E=E;
            
            A.S=[A.E.S]; %#ok<MCSUP>
            A.D=[A.E.D]; %#ok<MCSUP>
            
            tt={A.E.type};
            A.whi=A.E(find(strcmp(tt,'whitenoise'),1));
            A.tun=A.E(find(strcmp(tt,'tuning'),1));
            A.mov=A.E(find(strcmp(tt,'movies'),1));
            
            
        end
        
        function MisMatchCheck(A)
           % Checks for mismatch in the number of neurons between trial and
           % returns an error if there is one.
            
           nNeurons=arrayfun(@nN,A.S);
           
           if ~all(nNeurons==nNeurons(1))
                error(['Your experiments have different numbers of ' ...
                        'neurons.  Check to make sure these experiments do '...
                        'all correspond to the same cat and penetration.  If '...
                        'so, maybe a neuron just died between experiments.']); 
           end
        end
        
%         function selCat=get.selCat(A)
%             
%             d=dbstack;
%             
%             
%             list={A.E.name};
%             
%             k=0;
%             
%             function setix(val)
%                k=val;
%                delete(h);
%             end
%             
%             h=uicontextmenu;
%             cellfun(@(nm,i)uimenu(h,'label',nm,'callback',@(e,s)setix(i)),list,num2cell(1:length(list)));
%             set(h,'Visible','on');
% %            
%             waitfor(h,'Visible','off');
%             
%             pause(.05); % Needed to ensure that setix runs before k is tested.
%             
%             if k==0
%                 error('MATLAB:getselector:noselection','No Cat selected.  Actually this is ok, it was just mode convienient to use and exception here.  Sorry about the red!');
%             else
%                 selCat=A.E(k);
%             end
%         end
        
        function alignCells(A)
           % This method ensures that the cells in different Experiments on
           % the same cat have the same alignment in the Raster.  
           % Programatically speaking, it ensures that
           % A.C(a).S.T{i,:} refers to the same cell as A.C(b).S.T{i,:}
           
           
            idss=cellfun(@(x)x(:),{A.S.ids},'uniformoutput',false);
            
            
            
            
            list=unique(cat(1,idss{:}));
            
%             nanids=nan(size(list));
            
            for i=1:length(A.S)
                [~,order]=ismember(idss{i},list);
                trn=cell(length(list),size(A.S(i).T,2));
                trn(order(order~=0),:)=A.S(i).T;
                
%                 theseids=nanids;
%                 theseids(order(order~=0))=idss{i};
                
                A.S(i).T=trn;
                A.S(i).ids=list;
            end
            
            A.ids=list;
            
        end
        
        function AA=splitCells(A,onlyfilled)
            % Assuming cells have been aligned, split the object A into
            % multiple objects, each with one cell.
            %
            % onlyfilled is a boolean indicating whether you'd just like to
            % use cells where all experiments have responses.
            
            if ~exist('onlyfilled','var'), onlyfilled=true; end
            
            if isempty(A.ids), A.alignCells; end
            
            AA=MinistersCat.empty;
            for i=1:length(A.ids)
                MC=A.copy;
                
                % Array of experiments with this cell active
                filled=arrayfun(@(X)ismember(A.ids(i),X.S.ids),A.E);
                
                % Skip if there are some experiments without this cell.
                if ~all(filled) && onlyfilled, continue; end
                
                
                cellname=['#' num2str(A.ids(i))];
                
                for j=1:length(A.E)
                    cellix=A.ids(i)==A.E(j).S.ids;
                    MC.E(j).S.ids=MC.E(j).S.ids(cellix);
                    MC.E(j).S.T=A.E(j).S.T(cellix,:);
                    MC.E(j).S.name=[A.E(j).S.name cellname];
                    MC.E(j).name=[A.E(j).name cellname];
                
                    MC.E=MC.E; % Force the set function.
                end
                
                MC.name=[MC.name cellname];
                                
                AA=[AA MC]; %#ok<AGROW>
                
            end
                        
        end
        
        function AA=splitTypes(A)
            % Assuming cells have been aligned, split the object A into
            % multiple objects, each with one cell.
            %
            % onlyfilled is a boolean indicating whether you'd just like to
            % use cells where all experiments have responses.
                       
            AA=MinistersCat.empty;
            for i=1:length(A.E);
                MC=MinistersCat;
                MC.E=A.E(i);
                MC.name=A.E(i).name;
                
                AA=[AA MC];
                
            end
                        
        end
        
        function takeMaxCell(A)
            % Given all the experiments, this selects the cell that, on 
            % average, fired the most.  And throws the others away.
            % Firing is normalized to the experiment before averaging.
            %
            % Note that it is expected that "alignCells" has been called
            % first, which it should in any normal situation.
                       
            % Verify that cells are aligned
            idss={A.S.ids};
            assert(isequal(idss{:}),'The cells are not aligned between experiments.  Call "alignCells" first');
            
            % Get total firing, normalized to experiment
            fire=cell2mat(arrayfun(@(S)sum(S.nS,2),A.S,'uniformoutput',false));
            fire=bsxfun(@rdivide,fire,sum(fire,1));
            
            % Make a note of when different cells fire strongly.
            strongest=bsxfun(@eq,fire,max(fire));
            if nnz(any(strongest,2))>1
                fprintf('Note: Experiment %s contains different strongest-firing cells between different Stimuli.  Taking cell with hightest geo-mean over stimuli\n',A.name);
            end
            
            % Find the max cell and take it
            [~,maxCell]=max(mean(fire,2));
            for i=1:length(A.S)
               A.S(i).T=A.S(i).T(maxCell,:);
               A.S(i).ids=A.S(i).ids(maxCell);                
            end
            
            
        end
        
    end
    
    methods % Plotting
        
        function TheMenu(A)
            
           A.menu4(A.name,{'GrabCat','Spike_Counts', 'FanoComp', 'StatComp'});
            
        end
        
        function StatComp(A,stat)
            
            if ~exist('stat','var'), stat='isi'; end
            
            % Set Regional Variables
            [Dist xlab nC nR upperlim]=deal([]);
            nSS=1000; % Number of samples to use in kurtosis calc
            nT=500;   % Number of trials to use in kurtosis calc
            isicount=cell(1,length(A.E));
            
            function GrabData
                hw=waitbar(0.5,'Hold on.. calculating');
                % Dist will be a cell (over experiments) of cells (over neurons) 
                Dist=cell(size(A.E));
                upperlim=val{3}();
                
                for i=1:length(A.E); % For each experiment
                    switch val{2}()
                        case 'isi'
                            Dist{i}=A.E(i).S.isidist(upperlim);
                            xlab='ISI (s)';
                            isicount{i}=cellfun(@length,Dist{i});
                        case 'CV' % 
                            Dist{i}=A.E(i).S.CVdist(upperlim);
                            xlab='Coefficient of Variation (s)';
                            isicount{i}=cellfun(@length,Dist{i});
                        case 'kurtosis'
                            
                            % isi distribution...
                            dis=A.E(i).S.isidist(upperlim);
                            
                            isicount{i}=cellfun(@length,dis);
                            
                            % Get kurtosis of nT samples of nSS points from the isi distribution of this neuron 
                            Dist{i}=cellfun(@(D) kurtosis(randss(D,[nSS,nT])), dis,'uniformoutput',false);
                            
                            xlab=sprintf('Kurtosis of %g subsamples of %g ISIs',nT,nSS);
                            
                        otherwise
                            error WTF
                    end
                end
                delete(hw);
                
            end
                
            function PlotData
                GrabData;
                nR=length(Dist);
                nC=max(cellfun(@length,Dist));
                hAx=nan(nR,nC);
                for i=1:nR
                    nS=sum(A.E(i).S.nS,2);
                    for j=1:length(Dist{i})
                        hAx(i,j)=subplot(nR,nC,(i-1)*nC+j);
                        hist(Dist{i}{j},40);
                        xlabel (xlab)
                        ylabel count
                        title (sprintf('%s, neuron %g: from %g isi''s',A.E(i).name,j,isicount{i}(j)));
                    end                
                end
                U.linkmaxes(hAx(ishandle(hAx)),'x');
            end
            
            function KSres
                
                txt='';
                for ii=1:nC
                    txt=sprintf('%sNeuron %g - Probability of Same distribution :\n',txt,ii);
                    for jj=1:length(Dist);
                        for kk=1:jj-1;
                            [~,score]= kstest2(Dist{jj}{ii},Dist{kk}{ii});
                            txt=sprintf('%s%s-%s: %g\n',txt,A.E(jj).C.ext,A.E(kk).C.ext,score);
                            
                        end
                    end
                    txt=sprintf('%s\n',txt);
                end
                
                warndlg(txt,'I''m sorry, you have KS');
            end
                                    
            U=UIlibrary;
            [hB val]=U.buttons({'KS-test results',{'isi','CV','kurtosis'},'~ISI lim#0.15'});
                        
            set(hB(1),'callback',@(~,~)KSres);
            set(hB(2),'callback',@(~,~)PlotData);
            set(hB(3),'callback',@(~,~)PlotData);
            
            PlotData;
            
        end
        
        function Spike_Counts(A)
            
            
            N=length(A.E);
            for i=1:length(A.E)
                subplot(N,1,i);
                plot(A.E(i).S.nS');
                xlabel 'Trial Number'
                ylabel '# Spikes'
                title (A.E(i).name);
                
            end
            
            
        end
        
        function FanoComp(A)
            
            [FF mn]=A.S.FanoSmooth;
            
            figure;
            time=A.S.TStimeVec;
            
            nR=length(A.E);
            nC=max(cellfun(@length,Dist));
            
%             allids=
            
            for i=1:nR
                
                
                for j=1:nC
                   subplot(nR,nC,(i-1)*nC+j);
                    
                    
                end                
                
            end
            mplot(time,mn,'color','r');
            
            
            
        end
        
        function Plot_Raster(A)
           U=UIlibrary;
           
           
           [hAx]=U.figtype('cols',length(A.E));
           
           [hB type]=U.buttons({{'Cell,Cond,Trial','Cell, Trial','Cond,Trial,Cell'}});
           function replot
               for i=1:length(hAx)
                   A.E(i).S.Plot_Raster(hAx(i),hB,type);            
               end
               
           end
           replot;
            
        end
        
    end   
        
    methods % Analytical
        
        function FF=FanoMean(A)
            % F spits out a matrix of size nNeurons x nStimuli,
            % representing the mean Fano-Factor over trials
                    
            A.MisMatchCheck;
                        
            FF=nan(A.E(1).S.nN,A.nE);
            for i=1:A.nE
                FF(:,i)=mean(A.E(i).S.FanoFactor,2);             
            end
        end
        
        function nE=nE(A)
           nE=length(A.E); 
        end
        
        function [cell,count]=SpikerRank(A,justfirst)
            % Returns the magnitude of spiking in ranked order
            
            A.MisMatchCheck;
            
            nSpikes=sum(cell2mat(arrayfun(@(x)sum(nS(x),2),A.S,'uniformoutput',false)));
            
            [count cell]=sort(nSpikes,'descend');
            
            if justfirst
                % Just return the most powerfully spiking cell.  (useful if
                % calling from arrayfun);
                cell=cell(1);
                count=count(1);
            end
            
            
        end
        
        function nN(A)
            
            
            
        end
        
    end
    
    methods (Static)
                
        function figmerge
            
            
        end
        
        function M=go
            M=MinistersCat;
            M.GrabCat;
%             M.TheMenu;
        end
        
        function N=ListLength
            
            [~,ids]=MinistersCat.GrabList;
            
            N=length(ids);
            
        end
        
        function [F IDs map]=GrabList
            
            F=FelineFileFinder; F.autoload=true; F.Start;
            
            [IDs,~,map]=unique(strcat({F.E.cat}','~', {F.E.stage}'));
            
        end
        
        function MC=GiveMeCats(plural)
            
            if ~exist('plural','var'), plural=true; end
            
            F=FelineFileFinder; F.autoload=true; F.Start;
            
            [IDs,~,map]=unique(strcat({F.E.cat}','~', {F.E.stage}'));
            
            if plural, mode='muliple';
            else mode='single';
            end
            
            [sel,ok] = listdlg('ListString',IDs,'PromptString','Select an experiment set','SelectionMode',mode);
            if ~ok, return; end
            
            
            MC=MinistersCat.empty;
            
            for i=1:length(sel)
                ix=find(map==sel(i));
                SC=StimCat.empty;
                
                k=1;
                for j=1:length(ix)
                   SC(k)=StimCat;
                   try
                      SC(k).GrabCat(F.E(ix(j)));  
                      k=k+1;
                   catch ME
                      disp(ME.getReport);
                   end
                end
                MC(i).E=SC;
                MC(i).name=IDs{sel(i)};
                
                MC(i).alignCells;
            end  
            
            
        end
        
        
    end
    
end