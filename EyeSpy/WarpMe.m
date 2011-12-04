classdef WarpMe < handle
    
    properties
        
        vert; % n x 2 list of vertices.  
        
        desang; % n-2 x 2 list of desired angles connecting vertices.
        
        pull=@(r)1./r.^2;
        
        rigidity=.1;
        attraction=.1;
        
    end
    
    properties (Transient)
        
        
        im; % Temporary storage of image, to save computation
        imsum
        
    end
    
    methods
        
        function draw(A,im)
            
            colormap(gray);
            
            imagesc(im);
            
            [x y]=ginput;
            
            hold on;
            
            plot (x,y);
            
            A.vert=[x y];
            
            A.desang=A.vert2ang(A.vert);
            
            
            
        end
        
        function fit(A,im,steps)
            % Randomly draw pixels from the image and make them 'pull' on
            % the pixels.
            
            generalPull=0.1;
            
            batchsize=5;
            
            colormap gray;
            imagesc(im);
            hold on;
            
            points=fliplr(A.sampleFrom(im,steps));
            
            hL=nan; hP=nan;
            
            mom=zeros(size(A.vert));
            for i=1:batchsize:steps
                
                ix=i:i+batchsize-1;
                
                formForce=A.rigidity*A.bendForce(A.vert,A.desang);
                pullForce=A.attraction*A.pullNearest(A.vert,points(ix,:),generalPull);
                
                f=formForce+pullForce;
                
%                 mom=mom+f;
                A.vert=A.vert+f;
                
                delete(hL(ishandle(hL)));
                delete(hP(ishandle(hP)));
                
                hP=plot(points(ix,1),points(ix,2),'*b');
                hL=plot(A.vert(:,1),A.vert(:,2),'r*');
                
                
                drawnow;
            end        
            
            
            
        end
        
        
        function points=imdraw(A)
            
            
            
            
        end
        
        
    end
    
    methods (Static)
        
        function points=sampleFrom(D,n)
           % Draw samples from a probability distribution D.
           % D doesn't need to be normalized.
           % Samples will be returned as a size(n,d) matrix, where n is the
           % number of samples desired and d is the dimension of D
           
           sz=size(D);
           ix=randsample(numel(D),n,true,D(:));
            
           s=struct;
           s(length(sz)).a=[];
           
           [s.a]=ind2sub(sz,ix);
           
           points=cat(2,s.a);
           
           
        end
        
        function dang=vert2ang(vert)
           % take in an n x 2 list of vertices, return a n-2 x 2 lit of
           % angles connecting them
           
           d=diff(vert);
           
           ang=atan2(d(:,1),d(:,2));
           
           dang=diff(ang);
           
        end
        
        function f=bendForce(vert,desang,func)
            % The force acting on each vertex due to being out of alignment
            % with the desired angles.
            
            realang=WarpMe.vert2ang(vert);
            
            diss=realang-desang; % n-2 x 1 vector.. difference between real, desired angles
                        
            d=diff(vert);   % n-1 x 2 vector .. vectors connecting vertices.
            
            dd=[-d(:,2), d(:,1)]; % n-1 x 2 vector .. normals to these vectors.
            
            leftpush=bsxfun(@times,diss,dd(1:end-1,:));
            rightpush=bsxfun(@times,diss,dd(2:end,:));
            
            f=zeros(size(vert));            
            f(1:end-2,:)=leftpush;            
            f(3:end,:)=f(3:end,:)+rightpush;            
            f(2:end-1,:)=f(2:end-1,:)-leftpush-rightpush; % For every action...
                            
            if exist('func','var')
                f=func(f);
            end
            
        end
        
        function f=pullForce(points,attractors,distfun)
            % points: nx2 vector of points
            % attractors: nx2 vector of attractors
            %
            % f: the pull on these points.
            
%             sa=size(attractors);
            
            %
            vecs=bsxfun(@minus,permute(attractors,[3,2,1]),points);
            % vecs (i,:,j) is the vector from attractor j to point i.
            
            mag=distfun(sqrt(sum(vecs.^2,2)));
            
            f=sum(bsxfun(@times,vecs,mag),3);            
            
        end
        
        function f=pullNearest(points,attractors,general)
            % This one just applies a unit force on the closest point to
            % each attractor.  Basically implements a nearest neighbour
            % thing.
            %
            % General is a number (should be small and positive, like .01),
            % that allows non-winning points to slowly drift towards the
            % correct space.
            
            if ~exist('general','var'), general=0; end;
            
            vecs=bsxfun(@minus,permute(attractors,[3,2,1]),points);
            % vecs (i,:,j) is the vector from point i to attractor j.
            
            mag=sum(vecs.^2,2);  % mag is nP x 1 x nA.
            
            closest=bsxfun(@eq,mag,min(mag))+general; % nP x 1 x nA 
            
            % Sum the pulls of the winnding vecotrs.
            normvecs=bsxfun(@rdivide,vecs,sqrt(mag)); % note-quite inefficient-should normalize after.
            f=sum(bsxfun(@times,closest,normvecs),3);
            
            
            
        end
                
    end
    
    
end