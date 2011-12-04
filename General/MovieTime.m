classdef MovieTime < handle
    
    properties
        
        movlist=struct('movie',{},'frametimes',{},'soundtrack',{});
        
        U=UIlibrary;
        
        hB;
        hF;
        val;
    
        ix;
        
        M;
        frametimes;
        soundtrack;
        
        playing=false;
        
        actuallyplaying=false;
        
        frm=1;
        
    end
    
    
    methods
        
        function A=MovieTime(movies,frametimes,soundtracks)
            
            if ~exist('frametimes','var'), frametimes=[]; end
            if ~exist('soundtracks','var'), soundtracks=[]; end
            
            
           A.movlist=struct('movie',cell(1,length(movies)),'frametimes',{[]},'soundtrack',{[]});
           if iscell(movies)
               [A.movlist.movie]=movies{:};
               if ~isempty(frametimes)
                    [A.movlist.frametimes]=frametimes{:};
               end
               if ~isempty(soundtracks)
                    [A.movlist.soundtrack]=soundtracks{:};
               end
           else
               A.movlist.movie=movies;
               A.movlist.frametimes=frametimes;
               A.movlist.soundtrack=sountracks;  
           end
            
            
        end
        
        function ix=get.ix(A)
            ix=A.val{1}();
        end
            
        function M=get.M(A)
            M=A.movlist(A.ix).movie;
        end
        
        function set.playing(A,val)
           A.playing=val;
           if val
               set(A.hB(2),'string','pause');
           else
               set(A.hB(2),'string','play');
           end
        end
        
        function frametimes=get.frametimes(A)
            frametimes=A.movlist(A.ix).frametimes;
        end
                
        function GUI(A)
            
            A.hF=figure;
            
            [A.hB A.val]=A.U.buttons({1:length(A.movlist),'Play','Reset'});
            
            set(A.hB(3),'callback',@(e,s)reset);
            set(A.hB(2),'callback',@(e,s)playpause);
            set(A.hB(1),'callback',@(e,s)switchmov);
            
            function playpause
                A.playing=~A.playing;
                if A.playing, A.play; end
            end
            
            function reset
                A.playing=false;
                A.frm=1;
                A.play;                
            end
            
            function switchmov
               A.play;
            end
            
            colormap gray;
            
        end
        
        function play(A,startplaying)
           
            if isempty(A.hF) || ~ishandle(A.hF)
                A.GUI;
            end
            
            if ~exist('startplaying','var')
                A.playing=true;
            else
                A.playing=startplaying;
            end
            
            
            tix=A.ix;
            m=A.M;
            lims=quickclip(m);
            
            A.actuallyplaying=true;
            if isempty(A.frametimes)
                for i=A.frm:size(m,3);
                    imagesc(m(:,:,i),lims); 
                    title(sprintf('Frame %g of %g',i,size(m,3)));
                    drawnow;
                    if ~A.playing, 
                        A.frm=i;
                        break; 
                    elseif tix~=A.ix
                        break                        
                    end
                end
            else
                tic;
                tlen=A.frametimes(end)-A.frametimes(1);
                ilen=size(m,3);
                ts=A.frm/ilen*tlen;
                while true;
                    tim=toc+ts;
                    if tim>tlen, break; end
                    i=floor(ilen*(tim)/tlen)+1;
                    imagesc(m(:,:,i),lims);    
                    title(sprintf('Time: %g/%g',tim,tlen));
                    drawnow;
                    if ~A.playing, 
                        A.frm=i;
                        break; 
                    elseif tix~=A.ix
                        break        
                    end
                end
            end
            A.actuallyplaying=false;
            
                        
        end
        
    end
    
    
    
    
end