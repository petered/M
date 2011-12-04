classdef FormSwarm < handle
    
    properties
        
        Fm=0.01; % Memory Force
        
        Fc=0.01; % Conforming Force
               
        
        testim;
        targim;
        
        testloc;    % 2xn column vecotor of x,y locations
        targloc;
        
        neighbours; % 2 x n column of neighbour indeces
        
        angles; % 1 x n vector of angles between neighbours.
        desangles;
        
        desdist; % 2 x n vector of desire distances to neighbours
        
        vecs; % 1 x n x 2 
        
        autoview=true;
    end
    
    
    methods

        function set.testloc(A,val)
            A.testloc=val;
            
            if A.autoview
               A.view; 
               drawnow;
            end
            
        end
        
        function loadstart(A,filename)
        
            [A.testim A.testloc]=A.loadimg(filename,100);
                    
        end
        
        function loadtarg(A,filename)
            
            [A.targim A.targloc]=A.loadimg(filename,100);
            
        end
        
        function getneighbours(A)
            
            sz=size(A.testloc,1);
            
            nfun=@(sz,n)ceil(sz*rand(n,1));
            
            neigh=[nfun(sz,sz) nfun(sz,sz)];
            orig=(1:sz)';
            while true
                sames=bsxfun(@eq,neigh,orig);
                counts=sum(sames);
                if ~any(counts), break; end
                for i=1:size(neigh,2)
                    
                    neigh(sames(:,i),i)=nfun(sz,counts(i));
                end
            end
            
            A.neighbours=neigh;
            
        end
        
        function getangles(A)
                        
            A.angles=A.calcangles(A.vecs);
            
        end
        
        function initialize(A)
            
            A.getvecs;
            A.desdist=A.calcdist(A.vecs);
            
        end
                
        function [v01 v02]=getvecs(A)
        
            pt2=A.testloc(A.neighbours(:,1),:);
            pt1=A.testloc(A.neighbours(:,2),:);
            pt0=A.testloc;           
            
            v02=pt2-pt0;
            v01=pt1-pt0;
            
            A.vecs=cat(3,v01,v02);
            
        end

        function update(A)
            
            A.getvecs;
            
            push=A.calcpush(A.vecs,A.desdist)*A.Fm;
            
            A.testloc=A.testloc+push;
            
            
        end
        
        function view(A)
            
           im=A.loc2img(A.testloc,size(A.testim)); 
            
           imagesc(im);
           
           colormap(gray);
           
        end
        
                
        function shake(A,degree)
            if ~exist('degree','var'),degree=1; end
            A.testloc=A.testloc+degree*randn(size(A.testloc));
            
            
        end
            
        function play(A,n)
            
           A.view;
           for i=1:n
              A.update;
              drawnow();
           end
            
        end
        
    end    
    
    
    methods (Static)
               
        function push=calcpush(vectors,desdist)
            
            % Angle method (sucks)
%             ang=FormSwarm.calcangles(vectors);
%             meanvec=mean(vectors,3);
%             push=bsxfun(@times,meanvec,desangles-ang);
            
            dist=FormSwarm.calcdist(vectors);
            
            push=sum(bsxfun(@times,vectors,dist-desdist),3);
            

            
        end
        
        function dist=calcdist(vectors)
            dist=sqrt(sum(vectors.^2,2));
            
        end
            
        function ang=calcangles(vectors)
            v01=vectors(:,:,1);
            v02=vectors(:,:,2);            
            ang=atan2(v02(:,2),v02(:,1))-atan2(v01(:,2),v01(:,1));
            
        end
        
        function img=loc2img(locs,siz)
            
           mn=mean(locs)-siz/2;
           locs=bsxfun(@minus,locs,mn);
            
           fit=@(loc,sz)min(sz,max(1,round(loc)));
            
           veclocs=sub2ind(siz,fit(locs(:,2),siz(1)),fit(locs(:,1),siz(2)));
           img=false(siz);
           img(veclocs)=true;
            
        end
        
        
        function [img,pixlocs]=loadimg(filename,thresh)
        
            img=mean(imread(filename),3)<thresh;
            
            [y x]=ind2sub(size(img),find(img(:)));
            
            pixlocs=[x y];
            
            
        end
            
        
        
    end
    
    
end

