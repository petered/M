classdef Writer < Viewer
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        file;
        
        words;        
        
        w2d;
        d2w;
        
        dic;
        counts;
        
        H=struct('h','c');       % structure of hash vectors
        
        
        discount=0.5;
        strength=.5;
        
    end
    
    methods
        
        
        function menu(A)
            
            A.menu4('Text',{'Don''t Click!!'});
            
        end
        
        function A=Writer(file)
            
            
            if exist('file','var')
            A.file=file;
            end
        end
            
        
        function getwords(A)
        
            fid=fopen(A.file);
            c=textscan(fid,'%s');

            c=cellfun(@(x)x(isletter(x)),c{1},'UniformOutput',false);

            fclose(fid);
        
            A.words=c;
            
            [A.dic A.counts A.w2d A.d2w]=uniquecounts(A.words);
            
        end
        
        function getngrams(A,N)
            
            for n=1:N
                
                
            end
            
            
        end
        
        function Write(A)
            
            sp=A.d2w(1:2);
            fprintf('%s %s ',A.dic{sp});
            
            while true
               
                sp(end+1)=A.drawfrom(sp(end-1:end));
                
                fprintf('%s ',A.dic{sp(end)});
%                 pause(.5);
                
            end
            
            
        end
        
        function ShowDist(A,varargin)
            
            
            
        end
        
        function makeH(A,n)
            
            for i=1:n                                
                [A.H(i).h A.H(i).hlist]=hashDist(A,i);                
            end
        
        end
        
        function [h hlist]=hashDist(A,n)
            % Return the list of unique hashes and distribution for a given
            % n-gram length
            
            % Reality Check:
            % all words A.words(find(locs==locs(20))-2) should be the same
            % if n==2.
                        
            [hlist locs]=hashlocs(A,n);
            
            h=struct('w',cell(1,length(hlist)),'c',cell(1,length(hlist)));
            fprintf('Generating hashlist for ngrams of length %g...',n);
            perc=0;
            for i=1:length(h)
                [h(i).w h(i).c]=uniquecounts(A.d2w(locs==locs(i)));
                
                if i/length(h) > perc
                    fprintf('%g%%..',perc*100);
                    perc=perc+0.01;
                end
            end
            disp Done;
                        
        end
        
        function [hlist locs]=hashlocs(A,n)
            % h is the list of unique hash codes
            % locs is a list the length of A.words defining the index of
            %   the hash code preceding each word
            
            hvec=hashVec(A,n);
            
            [hlist garb locs]=unique(hvec);
            
            
        end
            
            
        function hvec=hashVec(A,n)
            % hvec is a vector of length (length(A.words)), where each
            % element represents the hash preceding each word
            
            v=A.hasher(n);
            
            cv=round(conv(A.d2w,v,'valid'));
            
            hvec=[zeros(n,1); cv(1:end-1)]; 
            % Rounding because answer should be int-get rid of numerical errors          
                        
        end
        
        function hash=list2hash(A,els)
            
            v=A.hasher(length(c));
            hash=sum(v.*els);
            
        end
        
        
        function v=hasher(A,n)
            base=length(A.dic);
            v=base.^(0:n-1);
        end
        
        
        function word=drawfrom(A,context)
            % Returns a word
            n=length(context);
            
            if n==0
               ixword=ceil(rand*length(A.dic)); % Random word 
               word=A.dic(ixword);
               return;
                
            else
                
                hash=fliplr(A.hasher(n))*context;
                hix=find(A.H(n).hlist==hash,1);
                
                if isempty(hix)
                   word=A.drawfrom(context(2:end));
                   return;
                   %error('Couldn''t find the hash.  WHERE''S THE HASH?!'); 
                end
                
                ixword=ChineseRestaurant(A.H(n).h(hix).w, A.discount, A.strength);
                                
                if ixword==0 
                    word=A.drawfrom(context(1:end-1));
                    return;
                end
                
            end
            
            
            word=A.H(n).h(hix).w(ixword);
            
        end
            
        
    end
    
end

function [d count w2d d2w]=uniquecounts(w)

[d w2d d2w]=unique(w);
[garb ix]=unique(sort(d2w));
count=diff([0;ix]);

end




function ix=ChineseRestaurant(vec,discount,strength)
% Takes a random draw from a vector, with chances corresponding to
% size of each element

people=cumsum(vec);
tables=length(vec);

if rand <  (strength+tables*discount)/(people(end)+strength)
    ix=0; % New table
else
    ix=find(people-rand*people(end) > 0,1);
end



end


