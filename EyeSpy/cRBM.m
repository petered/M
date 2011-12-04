classdef cRBM < handle
    
	properties
        
        imdim;      % Dimensions of image, if using image block as input        
        
        % Parameters
        batch=100;      % Number of images to process in single batch (not yet used)
        eta=1;          % Learning Rate
        winit=0.001;    % Initial weight magnitude
        gibbs;          % Order of gibbs sampling.
        
        
        outlabels;  % Maps outputs onto output labels
        
        L=struct(cnx,{[]},'M', {struct('P',{},'S',{},'G',{},'W',{}) ,'B',{},'type',{}});  % Layer Structure

        % Stochastic transfer function
        f=@(x)round(rand(size(x))+logsig(x)-.5);
        
        % Smooth transfer function
        fs=@(x)logsig(x);
        dfs=@(x)logsig(x).*1-logsig(x);
        
    end

    
    
    methods % Keepers
        
        function init(A,insize,cnx,fsize,type)
            % cnx : a cell array of boolean connection matrices.
            %       or of single numbers, indicating the number of
            %       connections to the next layer (full connectivity is
            %       then assumed)
            % fsize:Array containing filter sizes of each map.  For now,
            %       filters are assumed to be square.
            % type: Cell array contining layer types.  Must be:
            %       'conv','sub',or 'full'.
            %
            % Note that this function will insert an 'input' layer before
            % this one.
            
            if ~isscalar(insize)
                error('Insize must be scaler.  Yes that means we only support square images for now.  Deal with it.');
            end
            
            A.L(1).W{1}=A.winit*randn(insize);
            for i=2:length(cnx)
                fp
                for j=1:length(A.L(i).M)
                A.L(i).W{i}
                end
            end
            
%             A.L(1).init([],insize,'in')
%             for i=2:length(cnx)
%                 A.L(i).init(cnx{i-1},fsize(i-1),type(i-1));
%             end
            
        end
        
        function rally(A,depth,n)
            % Rally between layers "depth" and "depth+1"
            % n-th order Gibbs sampling.
            
%             A.rally(A.L(1),A.L(2),
            
            
        end
        
    end
    
    methods % Maybe thrower awayers.
        
        
        function in=setup(im,nH,sF,types)
            % in: input matrix of images
            % sF: size of filters.
            % nH: number of hidden maps in each layer
            
            A.L(1).B=zeros(size(im));
            for i=2:length(nH)
               if strcmp(types{i},'conv')
                   
                   A.L(i).W=A.winit*randn(sF(i));
                   A.L(i).B=zeros(size(A.L(i-1).B-floor(sF/2)));
                   
%                else
                   
                   
                   
                   
               end
            end
            
            
            
        end
        
        
        function pairRun(A,in,dp)
            % Run the unsupervised training algorithm on a pair of layers.
            
            if (dp>1)
                error('Deeper pairs not supported yet');
            end
                
            
            A.L(dp).G=(filterBank(fil,in)+A.L(dp).B);
            A.L(dp).Sw=tf(filterBank(fil,A.L(i-1).Sw));
            
            
            
            
            
            if ~exist('p','var'), p=1; end
               
            
            
            
            
        end
        
                
        function out=wakePass(A,in,type)
            if nargin<3 || strcmpi(type,'stochastic')
                tf=A.f;
            elseif strcmpi(type,'smooth')
                tf=A.fs;                
            end
            % Waking pass
            A.L(1).Sw=in;
            for i=2:length(A.L)
                A.L(i).G=A.fs(filterBank(fil,A.L(i-1).Sw)+A.L(i).B);
                A.L(i).Sw=tf(filterBank(fil,A.L(i-1).Sw));
            end
            out=A.L(end).Sw;
        end
        
        function out=sleepPass(A,in,type)
            % Stochastic or smooth
            if nargin<3 || strcmpi(type,'stochastic')
                tf=A.f;
            elseif strcmpi(type,'smooth')
                tf=A.fs;                
            end
            
            A.L(end).Ss=in;
            for i=length(A.L)-1:-1:1
                A.L(i).Ss=tf(filterBank(A.L(i+1).W,A.L(i+1).Ss,true));
            end            
            out=A.L(1).Ss;
        end
        
        function trainround(A,in)
            % "in" should be an nUnits x nSamples matrix
            
            % Note: this has a few more transposes than it nees to.  Let's
            % cut down on that later.
            
            % Wake-Sleep Pass
            A.sleepPass(A.wakePass(in));
                        
            % Update Weight pass
            for i=2:length(A.L)
                A.L(i).W = A.L(i).W + A.eta * (A.L(i-1).Sw*A.L(i).Sw' - A.L(i-1).Ss*A.L(i).Ss')'/size(in,2);
            end
                        
        end

        function usTrain(A,in,epochs)
            % Unsupervised training of network    
            % "in" should be an nUnits x nSamples matrix
                                 
            if ~exist('epochs','var'); epochs=1; end
            
            nbatch=ceil(size(in,2)/A.batch);
            fprintf('Training network (unsupervised): %g epochs of %g batches\n',epochs,nbatch);
                        
            for i=1:size(in,3)
                A.trainround(in(:,:,i));        
            end
            
        end
        
        function strain(A,in,teacher,epochs)
            
            if ~exist('epochs','var'); epochs=1; end
            
            nbatch=ceil(size(in,2)/A.batch);
            fprintf('Training network (supervised): %g epochs of %g batches\n',epochs,nbatch);
                        
            for ep=1:epochs
                fprintf('  Epoch %g:  ',ep);
                k=1;
                for ba=1:nbatch-1
                    success=A.bprop(in(:,k:k+A.batch-1),teacher(:,k:k+A.batch-1));  
                    fprintf('%g:%g%%..',ba,success*100);
                    k=k+A.batch;
                end
                fprintf('%g..',nbatch);
                A.trainround(in(:,k:end));     
                disp Done                
            end
            
        end
        
        
    end
        
    
    
end




function out=filterBank(h,im,flipit)
% Using a a stack of 2d filters h (of size (x,y,nMaps)) fi
    if nargin<3, flipit=false; end

    out=nan(size(im,1)-floor(h,1),size(im,2)-floor(h,2),size(h,3),size(im,3));
    for i=1:size(im,3)
       for j=1:size(h,3)
           if flipit
               out(:,:,i)=out(:,:,i)+conv2(im(:,:,j),h(:,:,i),'full');
           else
               out(:,:,i)=out(:,:,i)+filter2(h(:,:,i),im(:,:,j),'valid');
           end
       end            
    end

end
