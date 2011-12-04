classdef Translatosaurus < handle
    
    properties
        
        V;  % Set of tranlationally independend vectors
        
        k;  % Number of 'on' elements in each col of V
        
        P;  % Set of projections...
        
    end
    
    methods
        
        
        function fill(A,n)
            
            A.V=A.tset(n);
            
            A.k=sum(A.V,1);
            
        end
        
        function vecmap(A)
            
            [im codex codey hI]=A.karnaugh();
            
            axis square;
            
            codes=[repmat(codex,[1,1,length(codey)]) ; repmat(permute(codey,[1 3 2]),[1 length(codex) 1])];
            
%             proj=codes;
%             proj(:,:)=A.tomax(proj(:,:));
            
            
            nx=size(codex,1); % number of elements to count in x-portion.
            
            names=A.vecnames;
            
            function labelone(ix,x,y,color)
                text(x,y,names(ix),'color',color,'HorizontalAlignment','center');
            end
            
            % Display labels for all vectors
            theone=nan(size(codey,2),size(codex,2));
            for i=1:size(codex,2)
                for j=1:size(codey,2)
                    
%                     vec=[codex(:,i);codey(:,j)];
                    vec=codes(:,i,j);
                    
                    theone(i,j)=find(A.isind(A.V,vec));
%                     theone(j,i)=find(all(bsxfun(@eq,proj(:,i,j),A.V)));
                    
                    labelone(theone(i,j),i,j,'b');

                    %count=nnz(A.k(1:theone)==A.k(theone));
                    %text(j,i,[num2str(A.k(theone)) '-' alph(count)],'color','b','HorizontalAlignment','center');
                end
            end   
            
            % Highlight labels corresponding to projections.
            for i=1:size(A.V,2)
                
%                 locx=find(all(repmat(A.V(1:nx,i),[1 size(codex,2)])==codex),1);
%                 locy=find(all(repmat(A.V(nx+1:end,i),[1 size(codey,2)])==codey),1);
                
%                 feq=@(x,y)all(eq(x,y));

                locx=find(all(bsxfun(@eq,A.V(1:nx,i),codex)),1);
                locy=find(all(bsxfun(@eq,A.V(nx+1:end,i),codey)),1);
                

                labelone(i,locx,locy,'r');
%                 count=nnz(A.k(1:i)==A.k(i));
%                 total=nnz(A.k==A.k(i));
%                 text(locx,locy,[num2str(A.k(i)) '-' alph(count) '-(' alph(total) ')'],'color','r','HorizontalAlignment','center');
                
            end
            
            set(hI,'hittest','off');
            set(gca,'buttondownfcn',@clickcb)
            
            hP=[];
            function clickcb(s,e)
                
                delete(hP(ishandle(hP)));
                
                p=get(s,'currentpoint');
%                 code=[codex(round(p(1,1)),:) ; codey(round(p(1,2)),:)];
%                 code=proj(round(p(1,1)),round(p(1,2)));
                
                locs=find(theone==theone(round(p(1,1)),round(p(1,2))));
                
                
                
                % find all cells with matching code
%                 locs=find(squeeze(all(bsxfun(code,proj))));
                
                [x y]=ind2sub([size(codey,2) size(codex,2)],locs);
                
                hold on
                hP=plot(x,y,'s','markeredgecolor','g','LineWidth',3,'MarkerSize',40);
                
                
            end
            
            
        end
        
        
        function [im codex codey hI]=karnaugh(A)
            % Karnaugh map of the vectors
            
            n=size(A.V,1);
            f=factor(2^n);
            nx=prod(f(1:2:end));
            ny=prod(f(2:2:end));
            
            codex=A.gray(log2(nx));
            codey=A.gray(log2(ny));
            
            nzx=sum(codex);
            nzy=sum(codey);
            
            [xx yy]=meshgrid(nzx,nzy);
            
            im=xx+yy;
            
            hI=imagesc(im);
            colormap gray
            
            title 'number of ones'
            
            codedisp=repmat('0',size(codex)); codedisp(codex(:))='1'; codedisp=fliplr(codedisp');
            
            
            set(gca,'xtick',1:nx,'xticklabel',codedisp);
            set(gca,'ytick',1:ny,'yticklabel',codedisp);
            
            
            
        end
        
        
        function addvects(A)
            % Given the karnaugh map, add the vectors.
            
            
            for i=1:size(A.V,2)
                text()
                
                
                
            end
            
            
            
            
        end
        
        function mindistplot(A,dist)
           
            D=A.minadjmat();
            
            if exist('dist','var')
                imagesc(D==dist);
            else
               imagesc(D); 
            end
            
            names=A.vecnames;
            
            set(gca,'xtick',1:length(D),'xticklabel',names);
            set(gca,'ytick',1:length(D),'yticklabel',names);
                
            colormap(gray);
            
        end
        
        function Cx=minadjmat(A)
            Cx=A.mindistmat(A.P);
        end
        
        function Cx=adjmat(A)
            Cx=A.distmat(A.P);
        end
        
        function names=vecnames(A)
            % Returns the name for each of the vectors.
            alph='a':'z';
            
            names=cell(size(A.k));
            for ix=1:length(A.k)
                count=nnz(A.k(1:ix)==A.k(ix));
                total=nnz(A.k==A.k(ix));
                names{ix}=[num2str(A.k(ix)) '-' alph(count) '/' alph(total)];
            end
            
        end
        
        function g=groups(A)
            
            Cx=A.adjmat==1;
            
            g=A.cxgroup(Cx);
            
            
        end
        
                
    end
    
    methods (Static)
        
        
        function g=cxgroup(Cx)
            % Takes a connection matrix, returns the list of groups
            
            
            
            function groupcheck(ix,k)
                % Recursively check group membership starting from point ix
                
                g(ix)=k;
                kids=find(Cx(ix,:));  % Find groups that this group is connected to.
                
                newkids=kids(isnan(g(kids)));
                
                for i=1:length(newkids)
                    groupcheck(newkids(i),k)
                end
            end
            
            
            id=0;
            g=nan(1,length(Cx));
            while true
                
                loc=find(g(isnan(g)),1);
                
                if isempty(loc)
                    break;
                else
                   id=id+1; 
                end
                
                groupcheck(loc,id);
                
            end
            
            
            
        end
                
        function [s]=tset(n)
            % The set of independent vectors of length n
            %
            % This probably isn't the world's most efficient method for
            % generating this set, but ey, that's life.
            
            
            
            % Step 1: Generate all possible vectors
            allvec=dec2bin(0:2^n-1,n)'=='1';
            
            % Step 2: Separate by number of "true's" annd filter
            % redundants.
            s=[];
            nums=sum(allvec);
            for i=0:n
                
                s=[s Translatosaurus.deredundify(allvec(:,nums==i))];                
            end
            
            
        end
        
        function A=linkmat(X)
           % Given a set of X column vectors, return the matrix of hamming 
           % distances between them.
           
           A=squareform(pdist(X','cityblock'));
                        
        end
        
        function code=gray(n)
            % Returns a grey-code boolean counting vector, where each
            % column is a number.  n is the number of bits.
            
            % Step 1: Generate binary counting vector
            
            vec=0:2^n-1;
            
            binvec=flipud(dec2bin(vec,n)')=='1';
            
            map=bin2gray(vec,'pam',2^n);
            
            code=binvec(:,map+1);
            
            
        end
        
        function is=isind(X,y)
            % X is a matrix of column vectors of length n. 
            % y is a column vector of length n
            % is is a vector determining which vectors in X are just
            % translations of y
            
            Y=repmat(y,[1 size(X,2)]);
            is=zeros(1,size(X,2));
            for i=1:length(y)
            	is=is | all(circshift(X,[i,0])==Y);
            end
            
        end
                
        function D=mindistmat(X)
            % Given a set of column vectors X, get a matrix of minimum
            % distances between them. 
            
            D=zeros(size(X,2));
            for i=1:size(X,2)
                % Inefficient, yes, but probably still better than only
                % computing above the diagonal, because then you gotta keep
                % chopping X.
                D(i,:)=Translatosaurus.mindist(X,X(:,i));
            end
            
        end
        
        function dist=distmat(X)
            % Given a set of column vectors X, get a matrix of minimum
            % distances between them. 
            
            dist=squareform(pdist(X','cityblock'))';
            
            
            
            
        end
        
        function dist=mindist(X,y)
           % Compute minimum distance between vector y and column-vectors 
           % in vector-set X.
           
           dist=inf(1,size(X,2));
           for i=1:length(y)
               dist=min(dist,sum(bsxfun(@(a,b)abs(a-b),X,circshift(y,i))));
           end
           
                        
        end
        
        
        function X=deredundify(X)
           % Filter out translationally non-independent column-vectors in
           % matrix X
           
           Y=zeros(size(X,2),size(X,1));
           for i=1:size(X,2)
               Y(i,:)=Translatosaurus.tomax(X(:,i))';
           end
           
           X=unique(Y,'rows')';
             
        end
        
        function X=tomax(X)
           % Project a vector X to it's max representation... that is, the
           % 
           % This was actually more complicated than expected!
           %
           % The maximal representation is defined as the first index of
           % the longest string of ones, with ties broken by the longest
           % string of zeros, and so on.
           
           if size(X,2)>1
               Z=nan(size(X));
               for i=1:length(X)
                  Z(:,i)=Translatosaurus.tomax(X(:,i));
                  X=Z;
                  return;
               end
           end
            
           d=diff(X(:));
           
           lens=diff([0;find(d);length(d)+1]);
           
           if mod(length(lens),2) % Add the edges to the start.
               startpad=lens(end);
               lens(1)=lens(1)+startpad; lens(end)=[];
           else
               startpad=0;
           end
           
%            if ~X(1) % Make sure it starts with ones.
%                ix=circhift(ix,1);
%            end
           
           wrap=@(ix,n)mod(ix-1,n)+1;
           
           candidates=~X(1)+1:2:length(lens);
           maxlen=max(lens(candidates));
           
           % General strategy:
           % We start with a vector 'lens' containing the lengths of each
           % string of ones/zeros (wrapped so no string of 1's or 0's is 
           % wrapped around the end.
           % 'candidates' are then taken as the indeces (in lens) of the
           % 1's, and filtered down to the longest sets of ones. 
           %
           % The while-loop then takes care of the tricky business of
           % tie-breaking by checking for which candidate has the next
           % longest string of digits.
           %
           % The 'if' condition is needed to break on a situation where a
           % vector is made up of multiple repetitions of a subvector (eg
           % 00110011)
           
           
           candidates=candidates(lens(candidates)==maxlen);
           kk=1;
           while length(candidates)>1

               cans=wrap(candidates+kk,length(lens));
               newmax=max(lens(cans));
               candidates(lens(cans)~=newmax)=[];
               kk=kk+1;
            
               if kk==length(lens), 
                   % Repetition situation: could maybe tighten this limit.
                   candidates=candidates(1);
                   break;
               end

           end
                   
           loc=wrap(sum(lens(1:candidates-1))-startpad,length(X));
           
           X=circshift(X(:),[-loc,0]);
            
            
        end
        
        
    end  
    
end