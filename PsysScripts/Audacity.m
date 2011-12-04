classdef Audacity < Viewer
    
    properties (SetObservable=true)
       T;           % Cell array of tracks
       fS=44100;    % Sampling frequency        
        
       hT;          % Hash codes for track (not used yet)
       
       
       S;           % States: Array storing the state of T
       
       Told;        % Old versions, for undo
       
       
       
       secretflag=false; 
    end
    
    
    methods % Housework
        
        function set.T(A,T)
            
            if ~A.secretflag
                A.Told{end+1}=A.T;
            end
            
            A.T=T;
            
            
        end
                
        function undo(A)
            
            if isempty(A.Told), return; end
                
            A.secretflag=true;
            A.T=A.Told{end};
            A.secretflag=false;
            
            A.Told(end)=[];
            
        end
                
        function savestate(A,name)
            % Save the current state of the object
            states={A.S.name};
            
            if any(strcmp(states,state))
                error('A state with that name is already saved');
            end            
            
            % Save the tracks
            new=A.makecopy();            
            
            
            ix=length(A.S)+1;
            
            A.S(ix).name=name;
            A.S(ix).time=datestr(now);
            A.S(ix).A=new;
                        
        end
        
        function B=makecopy(A)
            B = feval(class(A));
            p = properties(A);
            for i = 1:length(p)
                B.(p{i}) = A.(p{i});
            end
            
        end
        
        function B=loadfromstate(A,state)
            % Load a new audacity project from an old state.
            
            states={A.S.name};
            
            ix=strcmp(states,state);
            
            nsel=nnz(ix);
            if nsel==0
                error('No states matching that name exist');
            elseif nsel > 1
                disp 'WARNING: MULTIPLE STATES WITH THIS NAME EXIST.  TAKING THE FIRST'                
            end
            
            B=A.S(ix);
                        
        end
        
        function playfromstate(A,state,track)
            
            B=A.loadfromstate(A,state);
            B.play(track);
            
        end
        
        function batchjob(A,effect,tracks)
            
            A.secretflag=true;
            try
                arrayfun(effect,tracks);
            catch ME
                A.secretflag=false;
                rethrow(ME);
            end
            A.secretflag=false;
            A.T=A.T;
            
            
        end
        
        
    end
    
    methods % Adding/Merging/Exporting Tracks
        
        function [trackno file]=addfile(A,filename)
            if ~exist('filename','var')
                [file path]=uigetfile('*.wav','MultiSelect','on');
                if ~path, return; end
                if ischar(file), file={file}; end
                
                cd (path);     
                filename=strcat(path,file);
            end
                   
            for i=1:length(filename)
            
                [w fSS]=wavread(filename{i});            

                if length(A.T)>1 && fSS ~= A.fS
                    error('Can''t handle different frequencies now');
                end

                A.T{end+1}=w;
                trackno=length(A.T);
                A.fS=fSS;
            end
        end
        
        function trackno=addchord(A,time,freqs,amps,phases)
            % Adds a chord consisting of a some frequencies freqs and
            % amplitudes amps.  
            
            if ~exist('amps','var'), amps=ones(1,length(freqs))/length(freqs); end
            if ~exist('phases','var'), phases=zeros(1,length(freqs)); end
            
            
            t=linspace(0,time,floor(time*A.fS)+1)';
            
            x=zeros(size(time));
            for i=1:length(freqs)
                x=x+amps(i)*sin(2*pi*freqs(i)*t+phases(i));
            end
            
            if any(abs([max(x) min(x)]))>1, disp('WARNING: CLIPPING'); end
            
            A.T{end+1}=x;
            trackno=length(A.T);
            
        end        
        
        function trackno=addnoisetrack(A,time,amp)
                        
            if isempty(time), 
                len=length(A.T{end});
            else
                len=A.time2ix(time);
            end
                        
            A.T{end+1}=amp*(rand(len,1)-.5);
            trackno=length(A.T);
                                  
        end
        
        function trackno=merge(A,tracks,clearold)
           if ~exist('clearold','var'), clearold='add'; end
           
           lens=cellfun(@length,A.T(tracks));
           nsides=cellfun(@(x)size(x,2),A.T(tracks));
           
           mas=zeros(max(lens),max(nsides),length(tracks));
           for i=1:length(tracks)
               mas(1:lens(i),1:nsides(i),i)=A.T{tracks(i)};
           end
           x=sum(mas,3);
           
           switch clearold
               case 'replace'
                   A.T{tracks(1)}=x;
                   A.T(tracks(2:end))=[];
                   trackno=tracks(1);
               case 'add'
                   A.T{end+1}=x;
                   trackno=length(A.T);
               case 'return'
                   trackno=x;   
           end
            
            
        end
                
        function export(A,track,filename)
            
            if ~exist('filename','var');
                [f p]=uiputfile('*.wav');
                filename=[p filesep f];
            end
            
            wavwrite(A.T{track},A.fS,filename);
            fprintf('Created file: "%s"\n',filename);
        end
        
        function clear(A)
            
            A.T=[];
            A.fS=[];
            
            
        end
        
    end
    
    methods % effects
        
        
        function st2mon(A,track,method)
            % Change sterio to mono
            if ~exist('method','var'), method='mean'; end
            
            if numel(track)>1, A.batchjob(@(tt)A.st2mon(tt,method),track); return; end
            
            switch method
                case 'mean'
                    A.T{track}=mean(A.T{track},2);
            end
        end
        
        function fadein(A,track,t1,t2,type)
            if ~exist('type','var'), type='lin'; end
            
            ix=A.time2ix(track,[t1 t2]);
            len=diff(ix)+1;
            
            switch type
                case 'lin'
                    fader=linspace(0,1,len)';
                case 'quad'
                    fader=linspace(0,1,len)';
                    fader=-(fader-1).^2+1;
            end
            A.T{track}(ix(1):ix(2))=A.T{track}(ix(1):ix(2)).*fader;
        end
                
        function fadeout(A,track,t1,t2,type)
            if ~exist('type','var'), type='lin'; end
            
            ix=A.time2ix(track,[t1 t2]);
            len=diff(ix)+1;
            
            switch type
                case 'lin'
                    fader=linspace(1,0,len)';
                case 'quad'
                    fader=linspace(1,0,len)';
                    fader=-(fader-1).^2+1;
            end                     
            A.T{track}(ix(1):ix(2))=A.T{track}(ix(1):ix(2)).*fader;
        end
                
        function silence(A,track,t1,t2)
            
            if numel(track)>1, A.batchjob(@(tt)A.silence(tt,t1,t2),track); return; end
                
            
            ix=A.time2ix(track,[t1 t2]);
            
            A.T{track}(ix(1):ix(2),:)=0;
        end
        
        function amplify(A,track,factor)
            
            if numel(track)>1, A.batchjob(@(tt)A.amplify(tt,factor),track); return; end
            
            A.T{track}=A.T{track}*factor;
            
            if max(A.T{track})>1
                disp 'WARNING: max amplitude of y is in clipping range';
            end
        end
        
        function amp2max(A,track,factor)
           % Scale signal so that the max amp is factor
            
           A.T{track}=A.T{track}*factor/max(A.T{track});
           
           if factor>1
               disp 'WARNING: max amplitude will be in clipping range';
           end
                        
        end
                
        function noiseFilt(A,track,varargin)
            % Filters the track on the noise sample in range [t1 t2]
            % varargin can either be a range t1, t2
            % or a noise sample
            
            if numel(track)>1, A.batchjob(@(tt)A.noiseFilt(tt,varargin{:}),track); return; end
            
            if numel(varargin)==1 % Noise sample is provided                
                noisesamp=varargin{1};
                A.T{track}=vuvuvu(A.T{track},A.fS,noisesamp);                
            elseif numel(varargin)==2 % Time Range is provided
                t1=varargin{1};
                t2=varargin{2};
                A.T{track}=vuvuvu(A.T{track},A.fS,[t1 t2]);
            end
            
            
            
            
        end
        
    end
    
    methods % analysis
        
        function mas=cattracks(A,tracks)
            % Make a concatenated matrix of tracks in 3rd dimension
            lens=cellfun(@length,A.T(tracks));
            nsides=cellfun(@(x)size(x,2),A.T(tracks));
           
            mas=zeros(max(lens),max(nsides),length(tracks));
            for i=1:length(tracks)
               mas(1:lens(i),1:nsides(i),i)=A.T{tracks(i)};
            end
        end
        
        function m=meanamp(A,track,t1,t2)
            % Returns mean and standard deviation of amplitude
            if ~exist('t1','var'), t1=-inf; end
            if ~exist('t2','var'), t2=inf; end
            
            ix=A.time2ix(track,[t1 t2]);
            
            m=mean(abs(A.T{track}(ix(1):ix(2))));
            
        end
        
        function lims=lims(A,track)
            % Returns max,min amplitude of track in times t1,t2
        
            if ~exist('t1','var'), t1=-inf; end
            if ~exist('t2','var'), t2=inf; end
            
            ix=A.time2ix(track,[t1 t2]);
            
            lims(1)=max(A.T{track}(ix(1):ix(2)));
            lims(2)=min(A.T{track}(ix(1):ix(2)));
            
        end
            
        function [tx ix]=crossings(A,track,thresh,number)
            % Find locations where signal crosses thresh
            % Number is the number to look for.  Specifying number will
            % return a (ntracks x number) matrix, otherwise you'll get a cell
            % arrazy
            
            if ~exist('thresh','var'), thresh=0; end
                        
            if exist('number','var')
                crossfun=@(s,thresh,n)find(xor(s(2:end)>thresh,s(1:end-1)>thresh),n);
                ix=nan(numel(track),number);
                for i=1:length(track)
                    f=crossfun(A.T{track(i)},thresh,number);
                    ix(i,1:length(f))=f;
                end
                tx=(ix-1)/A.fS;
            else
                crossfun=@(s,thresh)find(xor(s(2:end)>thresh,s(1:end-1)>thresh));
                ix=arrayfun(@(tt)crossfun(A.T{tt},thresh),track,'uniformoutput',false);
                tx=cellfun(@(i)(i-1)/A.fS,ix,'uniformoutput',false);
            end
            
            
            
            
        end
        
        function [x fs]=grabrange(A,track,t1,t2)
           % Grab track over range 
            ix=A.time2ix(track,[t1 t2]);
            
            x=A.T{track}(ix(1):ix(2),:);
            fs=A.fS;
            
        end
           
        function onsettimes(A,track,thresh,mincross,gap)
            
            [tx ix]=crossings(A,track,thresh,number);
            
            
            
            
            
        end
    end
    
    methods % Visualizing
        
        function UIstart(A)
            
            A.menu4('Options:',{'addfile','plot','denoise'});
                        
        end
        
        function simpleplot(A,track)
            if ~exist('track','var'), track=1:length(A.T); end
            
            n=length(track);
            
            for i=1:n
                h(i)=subplot(n,1,i);
                plot(A.tvec(i),A.T{track(i)});
            end
            xlabel 'time (s)'
            linkaxes(h,'xy');
            
        end
        
        function [hL spacin]=mplot(A,track,varargin)
            
            clf;
            
            if ~exist('track','var'), track=1:length(A.T); end
            
            X=squeeze(mean(A.cattracks(track),2));
            xlabel 'time (s)'
            
            tvec=(0:size(X,1)-1)/A.fS;
            [hL spacin]=mplot(tvec',X,varargin{:});
            
            set(gca,'ytick',spacin(end:-1:1),'yticklabel',num2str(track(end:-1:1)'));
            
            set(hL,'buttondownfcn',@(e,s)soundoff);
            
            function soundoff
                ix=find(hL==gcbo,1);
                A.play(track(ix));                
            end
            
        end
        
        function play(A,track)
            if ~exist('track','var')
                track=1:length(A.T);
            end
            
            x=A.merge(track,'return');
            
            sound(x,A.fS);
            
        end
        
        function spec(A,track)
            if ~exist('track','var'), track=1:length(A.T); end
            
            n=length(track);
            for i=1:n
                h(i)=subplot(n,1,i);
                PlotSpec(A.T{track(i)},A.fS);
            end
            
            linkaxes(h,'xy');
            
        end
        
        function [h h2ix access]=plot(A,maxplots)
            % Outputs
            % h is the array of plot handles.
            % access lets you access any variable by name
            % h2ix returns a track number for a given handle click
        
            clf;
            
            if ~exist('maxplots','var'), maxplots=5; end
            
            nT=length(A.T);
            
            nPlots=min(nT,maxplots);
            
            ct=1:min(nT,nPlots);
            
            
            U=UIlibrary;
            hB=U.addbuttons({'<<','>>'});
            
            set(hB(1),'callback',@(e,s)dec);
            set(hB(2),'callback',@(e,s)inc);
%             set(hB(3),'callback',@(e,s)fini);
                        
            lh = addlistener(A,'Told','PostSet',@(s,e)replot);


            h=nan(1,nPlots);
            h2ix=@handle2index; % Get a track number given a subplot
            access=@accessme;  
            
            replot;
            hLink=[];
            function replot
                
               for i=1:nPlots
                   h(i)=subplot(nPlots,1,i);
                   plot(A.tvec(ct(i)),A.T{ct(i)});
                   ylabel(['tr:' num2str(ct(i))])
               end
               xlabel 'time (s)'
               
               hLink=U.linkmaxes(h,'xy');
                                              
%                set(gca,'ButtonDownFcn',@(s,e)clickityclick(s,e));
                          
            end
            
            function inc
                if ct(end)<nT
                    ct=ct+1;
                end
                replot;
            end
            
            function dec
                if ct(1)>1
                    ct=ct-1;
                end
                replot;
            end
            
            function index=handle2index(handle)
                index=ct(h==handle);
            end
            
            function var=accessme(varname)
                
                var=eval(varname);
                
            end
            
            
            
        end
        
        function [x ix]=grabSample(A)
            % Lets you select a sample from the track
            % x is the selected sample
            % ix is the index-range
            %
            % x ans ix will be empty if you fail to select a sample
            
            A.plot;
            hF=gcf;
            
            [h h2ix acc]=A.plot;
%             
%             oldtit=get(get(h(1),'title'),'string');
%             title 'GRAB A SAMPLE FROM A TRACK'
            
            
            
            set(hF,'WindowButtonDownFcn',@(s,e)select(true))
            set(hF,'WindowButtonUpFcn',@(s,e)select(false))
            
            U=acc('U'); % Grab Library
            
            hL=[nan nan];
            t1=[];
            t2=[];
            
            drawnow;
            disp('Drag the mouse to select a range from a track');
            
            
            function select(press)
                
                hax=gca;
                
                P=get(hax,'CurrentPoint');
                
                if press
%                     delete(hH(ishandle(hH)));
                    t1=P(1);
                    hL(1)=U.addline(P(1),'color','r');
                    disp 'Now Drag to select your range'
                    set(hF,'Pointer','ibeam');
                else
                    t2=P(2);
                    hL(2)=U.addline(P(1),'color','r');
                    
                    track=h2ix(gca);
                    ix=sort(A.time2ix(track,[t1 t2]));
                    t=A.ix2time(ix);
                    
                    
                    delete(hL);
                    hL=U.addline(t,'color','r');
                    
                    res=questdlg(sprintf('Select Range [%gs - %gs] of track %g?',t(1),t(2),track),'Range Selection','Yep','No! Try Again','No! I give up','Yep');
                    if isempty(res),res='No! I give up'; end
                    switch res
                        case 'Yep'
                            x=A.grabrange(track,t(1),t(2));
                            uiresume(hF);
                            disp 'Nice!'
                        case 'No! Try Again'
                            title 'GRAB A SAMPLE FROM A TRACK'
                            
                        case 'No! I give up'
                            x=[]; ix=[];
                            uiresume(hF);
                    end
                    
                    delete(hL);
                end
                              
            end
            
            uiwait(hF);
            set(hF,'Pointer','arrow');
%             title(oldtit);
            
        end
        
        function first=getstarts(A,thresh)
            % Provides a UI to allow the user to decide on what's a good
            % onset time.            
            
            nT=length(A.T);
            
            [tx ix]=A.crossings(1:nT,thresh);
            sttime=zeros(1,nT);
            ct=1:min(nT,5);
            first=grabfirst(tx,sttime,true);
            
            
            
%             col=lines;
            
            U=UIlibrary;
            hB=U.addbuttons({'<<','>>','export'});
            
            set(hB(1),'callback',@(e,s)dec);
            set(hB(2),'callback',@(e,s)inc);
            set(hB(3),'callback',@(e,s)fini);
            
            spacing=[];
            replot;
            
            function replot
                
               [~, spacing]=A.mplot(ct,'color',[.5 .5 .5]);
               
               hold on;
               hL=plot(first(ct),spacing,'g*');
               hL=plot(sttime(ct),spacing,'c+');
               hold off
               
               set(gca,'ButtonDownFcn',@(s,e)clickityclick(s,e));
                          
            end
            
            function inc
                if ct(end)<nT
                    ct=ct+1;
                end
                replot;
            end
            
            function dec
                if ct(1)>1
                    ct=ct-1;
                end
                replot;
            end
            
            function clickityclick(s,e)
                
                if strcmp(get(gcf,'selectiontype') ,'alt')
                    p=get(gca,'currentpoint');
                    
                    [~,loc]=min(abs(spacing-p(1,2)));
                    ix=ct(loc);
                    sttime(ix)=p(1);
                    first(ix)=grabfirst(tx(ix),sttime(ix));                    
                end
                replot;
            end
            
            function cross=grabfirst(crossings,start,dontplot)
                
                if nargin<3, dontplot=false; end
                cross=cellfun(@in,crossings,num2cell(start));                
                function x=in(x,st)
                    x=x(find(x>st,1));
                    if isempty(x),x=nan; end                    
                end
                if ~dontplot
                    replot;
                end
            end
            
            function fini
                export2wsdlg({'Onset Times'},{'OnsetTimes'},{first});
            end
            
            
        end
        
        function denoise(A)
            
            hH=helpdlg('Noise Removal.  Select a noise sample');
            uiwait(hH);
            x=A.grabSample;
            if isempty(x), return; end
            
            hH=waitbar(0.5,'Hold on, filtering');
            A.noiseFilt(A.tracks,x);
            delete(hH);
            
            
        end
        
        function parmplot(A,B)
            % Plot two Audacity objects in parallel
            
            [~,spacing]=A.mplot;
            h1=gca;
            
            B.mplot(B.tracks,'spacing',spacing);
            h2=gca;
            
            hL=linkaxes([h1,h2]);
            
            
            
        end
        
        
    end
    
    methods % useful
        
        function t=tvec(A,track)
            
            len=length(A.T{track});
            t=linspace(0,(len-1)/A.fS,len);
            
        end
        
        function ix=time2ix(A,track,time)
            % Convert time to indeces
            

            ix=floor(time*A.fS)+1;            
            ix=min(ix,length(A.T{track}));
            ix=max(ix,1);
            
        end
        
        function t=ix2time(A,ix)
            
            t=(ix-1)/A.fS;
            
        end
        
        function tracks=tracks(A)
            tracks=1:length(A.T);
        end
        
    end
    
    methods (Static)
        
        function dB=amp2dB(amp)
            dB=20*log10(amp);
        end
        
        function amp=dB2amp(dB)
            amp=10.^(dB/20);
        end
        
        
        
    end
    
end