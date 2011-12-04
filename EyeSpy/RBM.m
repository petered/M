classdef RBM < handle
% Restricted Boltzman machine

    properties
        
%         imdim;      % Dimensions of image, if using image block as input        
        
%         batch=100;
        
        eta=1;    % Learning Rate
        
        winit=0.001;  % Initial weight magnitude
        
        outlabels;  % Maps outputs onto output labels
        
        L=struct('W',{},'Sw',{},'Ss',{},'b',{});  % Layer Structure

        % Stochastic transfer function
        f=@(x)round(rand(size(x))+logsig(x)-.5);
        
        % Smooth transfer function
        fs=@(x)logsig(x);
        dfs=@(x)logsig(x).*1-logsig(x);
        
    end


    methods % Computational Schtuff
        
        function out=wakePass(A,in,type)
            if nargin<3 || strcmpi(type,'stochastic')
                tf=A.f;
            elseif strcmpi(type,'smooth')
                tf=A.fs;                
            end
            % Waking pass
            A.L(1).Sw=in;
            for i=2:length(A.L)
                A.L(i).Sw=tf(A.L(i).W*A.L(i-1).Sw);                
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
                A.L(i).Ss=tf(A.L(i+1).W'*A.L(i+1).Ss);
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

        function ustrain(A,in,epochs)
            % Unsupervised training of network    
            % "in" should be an nUnits x nSamples matrix
                                 
            if ~exist('epochs','var'); epochs=1; end
            
            nbatch=ceil(size(in,2)/A.batch);
            fprintf('Training network (unsupervised): %g epochs of %g batches\n',epochs,nbatch);
                        
            for ep=1:epochs
                fprintf('  Epoch %g:  ',ep);
                k=1;
                for ba=1:nbatch-1
                    fprintf('%g..',ba);
                    A.trainround(in(:,k:k+A.batch-1));        
                    k=k+A.batch;
                end
                fprintf('%g..',nbatch);
                A.trainround(in(:,k:end));     
                disp Done                
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
       
        function addlayer(A,nUnits,randomness)
            if ~exist('randomness','var'), randomness=A.winit; end
            A.L(end+1).W=randomness*randn(nUnits,size(A.L(end).W,1));
            
        end
        
        function success=bprop(A,in,teacher)
            % "in" should be an nInputs x nSamples matrix
            % "Teacher" should be a nOutputs x nSamples matrix
            
            out=A.wakePass(in,'smooth');
            err=teacher-out;
            
            dW=A.eta*(A.L(end-1).Sw*err')';
            
            A.L(end).W=A.L(end).W+dW;
            
            % Note.. need to continue with actual backprop
            if nargout>0
                [~,loc]=max(teacher,[],1);
                [~,gus]=max(out,[],1);
                success=nnz(loc==gus)/length(loc);
            end
            
            
        end
        
        
    end
    
    methods % Other Stuff
        
        function im=in2im(A,in)
            
           im=reshape(in,A.imdim(1),A.imdim(2),[]); 
            
        end
        
        function showRFs(A)
            %%
            
            if isempty(A.L)
                hW=warndlg('Need to Calculate Net''s first.  Run getPC.');
                uiwait(hW);
                return;
            end
            
            npics=5;
            
            F=UIlibrary;
            
            hax=F.figtype('cols',npics);
            hF=gcf;
            colormap (bone);
            
            hui=F.addbuttons('Back','Forward');
            set(hui(1),'callback',@(e,s)dec);
            set(hui(2),'callback',@(e,s)inc);
            
            ix=1;
            clims=quickclip(A.L(2).W);
            
            replot;
            
            function inc
                if ix<size(A.L(2).W,1)-npics+1
                    ix=ix+1;
                    replot;
                end
            end
            
            function dec
                if ix>1
                    ix=ix-1;
                    replot;
                end
            end
            
            function replot
                figure(hF);
                for i=1:5
                    subplot(hax(i));
                    imagesc(A.in2im(A.L(2).W(ix+i-1,:)'),clims);
                    title (['RF ' int2str(ix+i-1)]);
                    axis image;
                end
                                
            end
            
                                    
        end
        
        function varargout=setup(A,varargin)
            % nUnits is a vector indicating the number of units pwr layer
            % Either use 
            % in=A.setup(in,nUnits);    Uses 
            % A.setup(nUnits);  
            
            switch length(varargin)
                case 1
                    nUnits=varargin(1);
                case 2; % input/units syntax
                    im=varargin{1};
                    sz=size(im);
                    if length(sz)==3;                        
                        im=reshape(im,sz(1)*sz(2), sz(3));
                        nUnits=[sz(1)*sz(2) varargin{2}];
                        A.imdim=[sz(1) sz(2)];
                    elseif length(sz)==2
                        nUnits=[sz(1) varargin{2}];
                    end
                    varargout{1}=im;
            end
            
            LL=struct('W',{},'Sw',{},'Ss',{},'b',{});
            LL(1).b=zeros(nUnits(1),1);
            for i=2:length(nUnits)
                LL(i).b=zeros(nUnits(1),1);
                LL(i).W=randn(nUnits(i),nUnits(i-1))*A.winit;
            end            
            
            A.L=LL;

        end

        function movie(A,m,pausiness)
            
            if ndims(m)==2 && ~isempty(A.imdim) && size(m,1)==prod(A.imdim)
                m=reshape(m,A.imdim(1),A.imdim(2),[]);                
            end
            
            if ~exist('pausiness','var'), pausiness=.2; end
            
            hF=figure(666);
            colormap(gray);
            for i=1:size(m,3)
               imagesc(m(:,:,i));
               drawnow;
               pause(pausiness);     
               if ~ishghandle(hF); return; end
            end
            
        end
        
    end
    
    methods (Static)
        
        function t=lab2teach(lab)
            
            [u ,~, n]=unique(lab);
            
            t=false(length(u),length(lab));
            
            ix=sub2ind(size(t),n,1:length(lab));
            
            t(ix)=true;
            
        end
        
        
    end
    

end