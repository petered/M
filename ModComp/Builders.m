classdef Builders < handle
    
    
    properties
        
        locs;
        
        cage;
        
        autoview=true;
        
        hoods; % n x 4 array of neighbouthood values: left top right bottom
        
    end
    
    
    methods
        
        function set.locs(A,val)
            A.locs=val;
            
            if A.autoview
               A.view; 
               drawnow;
            end
            
        end
        
        function loadim(A,filename)
        
            [im loc]=A.loadimg(filename,100);
            
            A.cage=size(im);
            
            A.locs=loc;
            
        end
        
        function view(A)
            
           im=A.loc2img(A.locs,A.cage); 
            
           imagesc(im);
           
           colormap(gray);
           
        end
        
        function gethoods(A)
            
            A.hoods=A.gethood(A.locs);            
            
        end        
        
        function randomize(A)
            
            
            while true
                
                
                
            end
            
        end
        
    end
    
    methods (Static)
        
        
        function img=loc2img(locs,siz)
            
           mn=mean(locs)-siz/2;
           locs=bsxfun(@minus,locs,mn);
            
           fit=@(loc,sz)min(sz,max(1,round(loc)));
            
           veclocs=sub2ind(siz,fit(locs(:,2),siz(1)),fit(locs(:,1),siz(2)));
           img=false(siz);
           img(veclocs)=true;
            
        end
        
        function neigh=calcneighbours(locs)
            % Locs is an array of x,y coordinates (nx2)
            % neigh is a nx2x4 arrayof neighbouring coordinates.
            
            neigh=bsxfun(@plus,locs,cat(3,[-1 0],[0 1],[1 0],[0 -1]));
            
        end
        
        function [hood ix]=calchood(loc)
            % loc is a nx2 array.  
            % neigh is a nx2x4 arrayof neighbouring coordinates.
            
            
            neigh=Builders.calcneighbours(loc);
            
%             match=bsxfun(@eq,
            
%             if ~exist('img','var')
%                img=Builders.loc2img(loc,max(loc)+1); 
%             end

            nd=size(loc,2);
            np=size(loc,1);
            nn=size(neigh,3);

            modloc=reshape(loc,1,np,nd);
            modneigh=reshape(neigh,np,1,nd,[]);
            
            % match(i,j,k) will be nxnx4, and be true if 
            % loc i neighbours loc j in position k
  
            match=squeeze(all(bsxfun(@eq,modloc,modneigh),3));
            
            % next(i,k) is a nx4 array of neigbour values, true if
            % loc i has a neighbout at position k
            next=squeeze(all(match));
            
            % ix will be 
            hood=zeros(np,nn);
            for i=1:nn
                locs=find(next,i);
                hood(next(:,i))=find(next(:,i));
            end

% 
%             neigh=pdist(loc','cityblock')==1;
% 
%             hood=false([size(loc) 4]);
            
            
            
        end
        
        
        function [img,pixlocs]=loadimg(filename,thresh)
        
            img=mean(imread(filename),3)<thresh;
            
            [y x]=ind2sub(size(img),find(img(:)));
            
            pixlocs=[y x];
            
        end
            
        
        
    end
    
end