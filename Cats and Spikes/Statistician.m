classdef Statistician < Viewer
% This class collects statistics.  On EVERYTHING!
% 
% Basically, you have some subclass define your object array C.  C will
% be an array of the objects you're interested in looking at.
% 
% You then define 'stats', a structure array, containing the handles of
% functions that extract statistics from the dataset.  
%
% When you run the 'crunch' command, it .. well .. it just crunches
    
    
    properties (Abstract)
        
        C;  % Collection of objects of interest.  Assumed to be a handle object
        
    end
    
    
    properties 
        
        preproc;        % Handle to preprocessing function.
        filter;         % Handle to function with boolean output that decides whether to run the object.
        
        stats=struct('fun',{},'name',{},'dims',{},'groups',{});
        
        groups=struct('fun',{},'name',{});  % Groups of cat experiments
        
        D;              % Data cell array size: {nSamples,nStats,nGroups}(nDim)
                
        copyCats=true;  % Whether to copy objects before running statistics on them.  This prevents their modification.
        
        Dm;             % Cell array of data matrices by stat {nStats,nGroups}(nSamples,nDim,nGroups)
        
        U=UIlibrary;    % Reference to library.
        
        proc;           % Cell array {nSamples,nStats} containing notes on processing
        
        notes;          % To describe what preprocessing was used, etc.
        
        included;       % Boolean vector {nSamples} of samples to include in tables, plots.
    
        extra;          % Just to contain whatever you want to attach
    end
    
    properties (Hidden)
       
        preprocessed=false;
        
    end
    
    methods
                
        function D=get.D(A)
            if isempty(A.D)
                A.crunch;
                A.Dm=[];
            end
            D=A.D;
        end
        
        function Dm=get.Dm(A)
            if isempty(A.Dm)
%                 gix=A.groupIX(A.groups,A.C);
                A.Dm=A.D2Dm(A.D,A.stats);
            end           
            Dm=A.Dm;
        end
        
        function prerun(A)
            
            
            for i=1:length(A.C)
               if ~isempty(A.preproc) 
                    A.preproc(Ci); 
               end
            end
            A.preprocessed=true;
            
        end
                
        function [D_ proc_]=crunch(A,stats_)
            % Crunch the statistics.
            %
            % Standard use: A.crunch;
            % If you request an output, the computed stats are not kept in
            % the object.
            %
            % not entering the stats_ input results in the stats property
            % being used.
            % if you do enter stats, it can be a structure (containing
            % name, groups, fun), or a function handle
            
            
            if ~exist('stats_','var'), stats_=A.stats; 
            elseif isa(stats_,'function_handle')
                stats_=struct('name',{''},'fun',{stats_});
            end
            
            % Apply the statistic function of each group.
            [D_ proc_]=deal(cell(length(A.C),length(stats_),length(A.groups)));
            
            hW=waitbar(0,'Computing Stats from Experiments');
            cleaner = onCleanup(@()delete(hW));
            
            for i=1:length(A.C)
                
                
                if ~isempty(A.filter) && ~A.filter(A.C(i))
                    D_(i,:)={nan};
                    proc_(i,:)={'filtered by general'};
                    if A.copyCats
                        A.C(i).name=[A.C(i).name ' (not included)'];
                    end
                    continue;
                end
                
                % Create a copy and run the numbers on it.
                if A.copyCats
                    Ci=A.copy(A.C(i));
                else
                    Ci=A.C(i);
                end
                
                if ~(A.preprocessed || A.copyCats) && ~isempty(A.preproc)
                   A.preproc(Ci); 
                end
                
                for j=1:length(A.groups)
                    thing=A.groups(j).fun(Ci);
                    if isempty(thing), continue; end
                    
                    for k=1:length(stats_)
                                                
                        if isfield(stats_(k),'filter') && ~isempty(stats_(k).filter) && ~stats_(k).filter(A.C(i))
                            proc_{i,j,k}='filtered by stat';
                            continue;
                        end
                        if isfield(stats_(k),'groups') && ~isempty(stats_(k).groups) && ~ismember(j,stats_(k).groups)
                            proc_{i,j,k}='group not included';
                            continue;
                        end
                        try
                            D_{i,k,j}=stats_(k).fun(thing);
                            proc_{i,k,j}='done';
                        catch ME
                            disp(getReport(ME,'extended'));
                            proc_{i,k,j}='error';
                        end
                            
                        
                    end
                end
                
                waitbar(i/length(A.C),hW,A.C(i).name);
            end
            
            if nargout==0
                A.D=D_;
                A.proc=proc_;
            end
        end
        
        function mat=groupMatrix(A)
            % Build a 4-D matrix (coord,sample,group,stat) of results, out
            % of the cell-array.  Ragged edges (caused by groups of
            % differing size, samples with different numbers of
            % dimensions), will be filled with nans.
            
            % First build a matrix.
            ix=cell(1,length(A.groups));
            for i=1:length(A.groups)
               ix{i}=find(arrayfun(A.groups(i).fun,A.C));                
            end
            
            len=cellfun(@length,ix);
            dim=cellfun(@numel,A.D);
                        
            
            % Indexed (Sample#,group#,stat#)
            mat=nan(max(len),length(A.groups),length(A.stats));
            
            
            Dn=cell2mat(A.D);
            for i=1:length(A.groups)
                mat(1:len(i),i,:)=permute(Dn(ix{i},:),[1 3 2]);
            end
            
            
            
        end

        
        
    end
    
    methods % GUI and plotting
        
        function GUI(A)
            % This GUI allows you to view all the data from  all the cats.  
            % Type "ScriptoCats" into the command line to learn how to 
            % access the data programatically.
            %
            % The table shows the results for each experiment/statistic 
            % The graphs show comparisons between the groups.  There's 
            % plenty of room to improve this interface.  Using  statistical
            % tests to compare groups, more fancy plots, pairwise 
            % comparisons, etc
            %
            % Double-clicking entries on the experiment list turns them on
            % or off for the graphs.  You can toggle labels on the points
            % on any graph by clicking on the point.  
            
            h=StatGUI;
            
            if isempty(A.included)
                A.included=true(size(A.C));
            end
%             set(gcf,'HandleVisibility','off');
            
            listexperiments
%             set(h.listExp      ,'string',{A.C.name},'value',1);
            set(h.listGroup    ,'string',{A.groups.name},'value',1);
            set(h.listStat     ,'string',{A.stats.name},'value',1);
            
            % File section callbacks
%             set(h.pushExp       ,'callback',@(e,s)pushExp);
            
            set(h.popExp        ,'callback',@(e,s)popExp);
            set(h.listExp       ,'callback',@(e,s)listExp);
            set(h.listGroup     ,'callback',@(e,s)listGroup);
            set(h.listStat      ,'callback',@(e,s)listStat);
            
            set(h.pushViewTable ,'callback',@(e,s)pushViewTable);
            set(h.pushViewGraph,'callback',@(e,s)pushViewGraph);
            set(h.pushViewGraphs,'callback',@(e,s)A.plotGroupStats);
            set(h.pushMake,'callback',@(e,s)A.plotDIY);
            
            
            selExp=     @()get(h.listExp,'value');
            selGroup=   @()get(h.listGroup,'value');
            selStat=    @()get(h.listStat,'value');
            
            set(h.popExp,'string',{A.actions.name});
            
            A.addHelpButton(h.figure1);
            A.exportButton(A,'A',h.figure1);
            
            
            function listexperiments
                checks=arrayfun(@(x)char(10006-2*x),A.included,'uniformoutput',false);
                set(h.listExp,'string',strcat(checks,' ',{A.C.name}));
            end
            
            function pushViewTable
%                 DD=A.D;

            	cellwin(squeeze(A.D(:,selStat(),:)),'RowName',{A.C.name}, 'ColumnName',{A.groups.name},'name',A.stats(selStat()).name);
            end
            
            function pushViewGraph
                A.plotStat(selStat());
            end
            
            function popExp
                if get(h.popExp,'value')
%                     funs=get(h.popExp,'UserData');
%                     fun=funs{get(h.popExp,'value')};
%                     fun(selExp());
                    C_=A.C(selExp());
                    try
                        A.actions(get(h.popExp,'value')).fun(C_);
                    catch ME
                        if ~strcmp(ME.identifier,'MATLAB:getselector:noselection')
                            rethrow(ME);
                        end
                    end
                    
                end
            end
                  
            function listExp
                if get(h.popExp,'value')
                    ix=selExp();
                    if isempty(ix), return; end
                    tx='';
                    for i=1:length(A.C(ix).E)
                        tx=sprintf('%s\n%s',tx,A.C(ix).E(i).summary);
                    end
                    set(h.textExperiment,'string',tx,'fontsize',8);
                
                    if strcmp(get(h.figure1,'SelectionType'),'open')
                        A.included(ix)=~A.included(ix);
                        listexperiments;
                    end
                    
                end
            end
                        
            function listGroup
                if get(h.popExp,'value')
                    ix=selGroup();
                    if isempty(ix), return; end
                    txt=sprintf('%s\n%s',A.groups(ix).name,func2str(A.groups(ix).fun));
                    set(h.textGroup,'string',txt,'fontsize',8);
                end
            end
            
            function listStat
                if get(h.popExp,'value')
                    ix=selStat();
                    if isempty(ix), return; end
                    txt=sprintf('%s\n%s',A.stats(ix).name,func2str(A.stats(ix).fun));
                    set(h.textStat,'string',txt,'fontsize',8);
                end
            end
                        
        end
                
        function plotGroupStats(A)
            
            figure;
            Dm_=A.Dm;
            
            n=length(A.Dm);            
            nC=ceil(sqrt(n));
            nR=ceil(n/nC);
            
            
            for i=1:length(Dm_) % For each stat that is...
                
                A.plotStat(i,subplot(nR,nC,i));
                
                    
            end
                        
        end
        
        function plotStat(A,statNo,hax)
                            
            if ~exist('hax','var'), figure; hax=subplot(1,1,1); end
            
            Di=A.Dm{statNo};
            sz=size(Di);
            dim=prod(sz(3:end));
            
            if ~isempty(A.stats(statNo).dims)
                assert(length(A.stats(statNo).dims)==dim,'Your set of dimension descriptions for statistic "%s", does not match the number of dimensions',A.stats(statNo).name);
            end
            
            subplot(hax);
            
            if dim>=1 && dim<=3  % 
                A.plot23Dstat(statNo)
            else
                subplot(hax);
                cla; 
                title('Sorry, can''t plot!');
            end
            
        end
        
        function plot23Dstat(A,statNo)
            % Plot a stat with a of a matrix 
            % statNo: Number ID'ing statistic.
            % hax: the axes to plot in.
                        
            
            toInclude=A.included(:) & ~any(isnan(A.Dm{statNo}),2);
            
            Di=A.Dm{statNo}(toInclude,:,:); % (nSamples,nGroups,nDims[])
            assert(ismember(size(Di,2),[1,2 3]),'This plotter just works for 1, 2 or 3-D stats');
            
            samples=A.C(toInclude);
            
%             Dii=permute(Di,[1 3 2]);
            
            dim=size(Di,2);
            
            function labelaxes
                
                gps=A.stats(statNo).groups;
                if isempty(gps), gps=1:length(A.groups); end
                
                if isempty(gps), return; end
                
                xlabel(A.groups(gps(1)).name);
                if dim>=2
                    ylabel(A.groups(gps(2)).name);
                    if dim>=3
                        zlabel(A.groups(gps(3)).name);
                    end
                end 
            end
            
            function plotmidline
                
                w=axis;
                range=[min(w(1:2:end));min(w(2:2:end))];
                
                hold on;
                switch dim
                    case 1
                        addline(0);
                    case 2;
                        plot(range,range,'--','color',[.5 .5 .5]);
                        axis square;
                    case 3;
                        plot3([range range [0;0]],[range [0;0] range],[[0;0] range range],'--','color',[.5 .5 .5]);
                        axis square;
                end
                hold off;
                
            end
            
            switch dim
                case 1
                    hP=hist(squeeze(Di));
                    xlabel(A.stats(statNo).name);
                case 2
                    hP=plot(Di(:,1),Di(:,2),'*');
                case 3
                    hP=plot3(Di(:,1),Di(:,2),Di(:,3),'*');
                    view(135,45);
            end
            
            set(hP,'buttondownfcn',@(e,s)pointClick(e,s));
            function pointClick(e,s)
%                 P=get(get(e,'parent'),'CurrentPoint');
%                 P=P(1,:);
%                 
%                 [~,ix]=min(sum(abs(bsxfun(@minus,Di,P)),2));
%                 
%                 PC=num2cell(Di(ix,:));
%                 text(PC{:},samples(ix).name);
%                 
                toggleLabels
            end
            
            hL=[];
            function toggleLabels
                if any(ishandle(hL)), delete(hL(ishandle(hL))); hL=[]; 
                else
                    hL=nan(1,length(samples));
                    for i=1:length(samples)
                        loc=num2cell(Di(i,:));
                       hL(i)=text(loc{:},samples(i).name);
                    end
                end
                
            end
            
            
            labelaxes();
            title(A.stats(statNo).name);
            
%             if ~isempty(A.groups)
%                 legend({A.groups.name});
%             end
            
            grid on
            
            
            plotmidline();
            
            axis equal;
            
        end
        
        function plotDIY(A)
            
            h=BilderBuilder;
            
            set(h.listStat,'string',{A.stats.name});
            
            set(h.figure1,'toolbar','figure');
            
            selDim=     @()get(h.listDim,'value');
            selGroup=   @()get(h.listGroup,'value');
            selStat=    @()get(h.listStat,'value');
            
            vecs=struct('name',{},'data',{});
            actData=[];
            
            
            set(h.pushXon,  'callback',@(e,s)setVec('x'));
            set(h.pushXoff, 'callback',@(e,s)clearVec('x'));
            set(h.pushYon,  'callback',@(e,s)setVec('y'));
            set(h.pushYoff, 'callback',@(e,s)clearVec('y'));
            set(h.pushZon,  'callback',@(e,s)setVec('z'));
            set(h.pushZoff, 'callback',@(e,s)clearVec('z'));
            
            axoff=[h.pushXoff h.pushYoff h.pushZoff];
            set(axoff,'enable','off');
            
            set(h.listStat, 'callback',@(e,s)gotstat);
            set(h.listGroup,'callback',@(e,s)gotgroup);
            
            
            set(h.checkLabels,'callback',@(e,s)toggleLabels);
            set(h.checkComp,  'callback',@(e,s)plotmidline);
            
%             set(h.listStat, 'string',{A.stats.name});
            gotstat;
            
            
            
            set(h.pushRelease,'callback',@(e,s)pushRelease);
            function pushRelease
               hFF=figure;
               hnew=copyobj(h.axes,hFF);
               set(hnew,'units','normalized','position',[0.13 0.11 0.775 0.815]);
            end
            
            set(h.push3D,'callback',@(e,s)push3D);
            function push3D
               if length(actData)<3, pushRelease; return; end
                
               hFF=figure;
               
               sp=.0775;
               wi=.23;
               
               nax=copyobj(h.axes,hFF);
               set(nax,'units','normalized','position',[.1 .46 .8 .53]);
               view(gca,[135,atan(1/sqrt(2))*180/pi]);
               
               nax=copyobj(h.axes,hFF);
               set(nax,'units','normalized','position',[sp sp wi wi]);
               view(nax,[0,90]);
               
               nax=copyobj(h.axes,hFF);
               set(nax,'units','normalized','position',[sp*2+wi sp wi wi]);
               view(nax,[0,0]);
               
               nax=copyobj(h.axes,hFF);
               set(nax,'units','normalized','position',[sp*3+wi*2 sp wi wi]);
               view(nax,[90,0]);
               
                
                
                
            end
            
            function gotstat
                
                if ~isempty(A.stats(selStat()).groups)
                    ix=A.stats(selStat()).groups;
                else
                    ix=1:length(A.groups); 
                end
                
                grn={A.groups.name};
                
                set(h.listGroup,'string',grn(ix));
                
                if get(h.listGroup,'value')>length(ix),
                    set(h.listGroup,'value',length(ix));
                end
                
                gotgroup;
                
            end
            
            function gotgroup
                
                ndim=size(A.Dm{selStat()},3);
                
                if isfield(A.stats,'dimnames') && ~isempty(A.stats(selStat()).dimnames)
                    opts=A.stats(selStat()).dimnames;
                else
                    opts=arrayfun(@num2str,1:ndim,'uniformoutput',false);
                end
                
                set(h.listDim,'string',opts);
                
            end
            
            function clearVec(ax)
                ix=ax=='xyz';
                vecs(ix).data=[];
                vecs(ix).name='';
                replot;
                set(axoff(ix),'enable','off');
            end
            
            function vec=setVec(ax)
                
                st=selStat();
                gr=selGroup();
                dm=selDim();
                
                vec=A.Dm{st}(A.included,gr,dm);
                
                ix=ax=='xyz';replot
                vecs(ix).data=vec;
                
                replot
                
                vecs(ix).name=[A.stats(st).name ' : ' A.groups(gr).name];
                
                if size(A.Dm{st},3)>1
                    dimnames=get(h.listDim,'string');
                    vecs(ix).name=[vecs(ix).name ' : ' dimnames{dm}];
                end
                
                replot;
                set(axoff(ix),'enable','on');
            end
            
            function replot
               
                k=arrayfun(@(x)~isempty(x.data),vecs);
                
                vv=vecs(k);
                actData=vv;
                nD=length(vv);
                cla(h.axes);
                switch nD
                    case 0
                        v=axis;
                        text(mean(v([1 2])), mean(v([3 4])),'No data added','FontSize',20,'HorizontalAlignment','center');
                        grid off;
                    case 1
                        addlines(vv(1).data(:));
%                         plot([vv(1).data(:) zeros(numel(vv(1).data),1)]);
                    case 2
                        plot(vv(1).data,vv(2).data,'+','MarkerSize',6);         
                    case 3
                        plot3(vv(1).data,vv(2).data,vv(3).data,'+');
                        view(gca,[135,atan(1/sqrt(2))*180/pi]);
                end                
                
                % Label the axes
                if nD>0
                    xlabel(vv(1).name);
                    if nD>1
                        ylabel(vv(2).name);
                        if nD>2
                            zlabel(vv(3).name);
                        else
                            zlabel('');
                        end
                    else
                        ylabel('');
                    end   
                    
                    grid on;
                else
                    xlabel('');
                end
                
                
                plotmidline;
                toggleLabels;
                
            end
            
            hL=[];
            function toggleLabels
                delete(hL(ishandle(hL))); 
                if ~get(h.checkLabels,'value'),return; end
                
                fullset={A.C(A.included).name};
                
                if isempty(actData), return; end
                
                nP=length(actData(1).data);
                
                hL=nan(1,nP);
                switch length(actData)
                    case 1
                        for i=1:nP
                            hL(i)=text(actData(1).data(i),0,fullset{i},'rotation',90);
                        end
                    case 2;
                        for i=1:nP
                            hL(i)=text(actData(1).data(i),actData(2).data(i),fullset{i});
                        end
                    case 3;
                        for i=1:nP
                            hL(i)=text(actData(1).data(i),actData(2).data(i),actData(3).data(i),fullset{i});
                        end
                end
            end
                        
            
            hM=[];
            function plotmidline
                
                delete(hM(ishandle(hM)));
                
                if ~get(h.checkComp,'value'),
                    axis auto
                    return;
                end
                
                w=axis;
                range=[min(w(1:2:end));min(w(2:2:end))];
                
                hold on;
                switch length(actData)
                    case 1
                        hM=addline(0);
                    case 2;
                        hM=plot(range,range,'--','color',[.5 .5 .5]);
                    case 3;
                        hM=[plot3([range range [0;0]],[range [0;0] range],[[0;0] range range],'--','color',[.5 .5 .5]); plot3(range,range,range,'--','color',[.8 .8 .8])];
                        
                end
                hold off;
                
                axis equal;
            end
            
            replot
            
            
        end
        
    end
    
    methods (Static)
        
        function ix=groupIX(groups,C)
           % Find indeces of groups given the groups structure and the 
           % object array C.;
           
           % First find the indeces corresponding to each group.
           if ~isempty(groups)
               ix=cell(1,length(groups));
               for i=1:length(groups)
                  ix{i}=find(arrayfun(groups(i).fun,C));                
               end
           else % eqv to 1 group with everyone invited.
               ix={1:length(C)};              
           end
            
            
            
            
        end
       
        function Dm=D2Dm(D,stats)
            % Convert the 3-D cell array D to a cell array of data matrices
            % to stat-based format..
            %
            % Inputs
            % -D.  The Data Matrix {nSamples,nStats,nGroups}(nDim)
            % -ix.  Cell array of group indeces {nGroups}(nSubjectsInGroup)
            %      
            %
            % Output
            % -Dm. {nStats}(nSamples,nGroups,nDim), which makes more sense
            %       for viewing the results
            %
            % Ragged edges are padded with nans.
            
%             maxGrpLen=max(cellfun(@length,ix));
            
            
            nStats=size(D,2);
            
%             
%             function maxipad(c,maxd)
%                 
%                 
%             end
            
            
            
            
%             statSizes=cellfun(@size,D,'uniformput',false); 
            
            
            
            
%             nDims=cellfun(@numel,D);
%             maxDims=max(nDims);
            
            Dm=cell(1,nStats);
            for i=1:nStats
                
                % Determine relevant groups (those not consisting of just
                % nans and empties)
%                 gps=squeeze(any(cellfun(@(x)~all(isnan(x(:))),D(:,i,:))));
                if isempty(stats(i).groups),
                    gps=1:size(D,3);
                else
                    gps=stats(i).groups;
                end
                                
                % Pad everything with nans so that all values of same stat 
                % are the same size.
                statSizes=cellfun(@size,D(:,i,gps),'uniformoutput',false); 
                maxStatDims=max(cellfun(@length,statSizes(:))); 
                statSizes(:)=cellfun(@(x)[x ones(1,maxStatDims-length(x))],statSizes(:),'uniformoutput',false); 
                maxStatSizes=max(cell2mat(statSizes(:)));
                D(:,i,gps)=cellfun(@(x,s)padarray(x,maxStatSizes-s,nan,'post'),D(:,i,gps),statSizes,'uniformoutput',false); 
                                
                
                                
                % If dimensions within stat are uneven, nanfill.
                mx=num2cell(maxStatSizes);
                Di=cell2mat(cellfun(@(x)reshape(x,1,mx{:}),squeeze(D(:,i,gps)),'uniformoutput',false));
                
                
%                 Di=nan(size(D,1),length(gps),maxDims(i));
%                 for j=1:length(ix)
%                     Di=cell2mat(cellfun(@(x)[x(:)' nan(1,maxDims(i)-numel(x))],D(ix{j},i),'uniformoutput',false));
%                 end
                
                Dm{i}=Di;
            end
            
            
        end
        
%        function gr=crossGroups(gr1,gr2)
%            % Combines groups by ANDing the selection functions of each
%            % pair.
%            
%            k=1;
%            gr=struct('name',{},'fun',{});
%            for i=1:length(gr1)
%               for j=1:length(gr2)
%                   gr(k)=Statistician.andGroups(gr1(i),gr2(j));
% %                   gr(k).name=[gr1(i).name ' & ' gr2(j).name];
% %                   gr(k).fun=@(x) gr1(i).fun(x) && gr2(j).fun(x);
%                   k=k+1;
%               end  
%            end
%                       
%        end
%        
%        
%        function gr=andGroups(gr1,gr2,name)
%            if exist('name','var')
%                gr.name=name;
%            else
%                gr.name=[gr1.name ' & ' gr2.name];
%            end
%            gr.fun=@(x) gr1.fun(x) && gr2.fun(x);
%        end
%        
       
   end
    
end