classdef ConvLayer < handle
    % This class represents a layer in a convolutional neural net.      
    
    properties
        
        N;      % Reference to parent network.  Expected to contain
                % - tf:    The transfer function (eg @logsig).
                % - eta:   Learning Rate
                % - winit: Initial weight magnitude
                
                
        cnx;    % Boolean connection matrix between this layer and the last
        
        M=struct('C',{},'P',{},'S',{},'G',{},'W',{},'x',{});
            % Map structure.  Fields:
            %   C: Current - summed over all incoming maps
            %   P: Probability - transfer function of current
            %   S: Sampled - Bernoilli sampling from P
            %   G: Gradient - Made by filtering subsequent layers.
            %   W: Weights - 3-D array of kernels to connecting to previous layer's maps
            %   x: Connections - Vector of indeces of connected maps in previous layer. 
                
        
        
        type;   % conv,sub,or full
        
    end
    
    methods % for RBM's
        
        function init(A,cnx,fsize,type)
            % cnx: the connection matrix (nMapsThis x nMapsLast)
            % fsize: the filter size (scalar)
            % type: the layer type ('conv','sub',or 'full')
            
            M_=struct('C',{},'P',{},'S',{},'G',{},'W',{},'x',{});
            
            
            edge=floor(fsize/2);
            msize=insize-edge;
            
            
            
            for i=1:size(cnx,1) % For each soon-to-be map in this layer
            
                cx=find(cnx(i,:));
                nx=length(M_(i).x);
                
                switch type
                    case 'in'
                        M_(i).S=zeros(fsize);
                        
                    case 'conv'
                        M_(i).x=cx;
                        M_(i).W=randn(fsize,fsize,nx)*L.N.winit;
                        
                        M_(i).B=randn(msize);
                        
                        for k=1:length(A.N.gibbs)
                            M_(i).C{k}=zeros(msize);
                            M_(i).P{k}=zeros(msize);
                            M_(i).G{k}=zeros(fsize,fsize,nx);
                            M_(i).S{k}=false(msize);
                        end
                                                
                    case 'sub'
                        error('Subsampling layers not supported yet');
                        
                    case 'full'
                        error('Fully connected layers not supported yet');
                end
                
            end
            
            A.M=M_;
            
        end
        

        function rally(L1,L2,input)
            % Conduct the 'rally' between two layers of a C-RBM, as shown in 
            % http://www.cs.sfu.ca/~mori/research/papers/norouzi_cvpr09.pdf, Algorithm 1.
            %
            % L1 corresponds to the visible, L2 to the hidden.

            if ~isequal(size(L1.M{1}.S{1}),size(input))
                error('Input image does not match the size of the input layer.  Trim it or something.');
            end
                  
            
            L1.M{1}.S{1}=input;
            
            
            for i=1:A.N.gibbs-1;
                forwardPass(L1,L2,i);
                backwaerPass(L1,L2,i);
            end
            forwardPass(L1,L2,A.N.gibbs,true);
                        
            learnSomething(L2);

            

        end
        
        function forwardPass(L1,L2,n,short)
            % Forward Pass
            if nargin<3, n=1; end
            if nargin<4, short=false; end
            
            for i=1:length(L2.M) % For each map...
                
                % Get edge size, initialize Current map, find connecting maps    
                L2.M(i).C(:)=L2.M(i).B(:);
                cx=find(L2.cnx(i,:));
                
                for j=1:length(cx) % For previous map that it's connected to
                    L2.M(i).C=L2.M(i).C{n}+filter2(L2.M(i).W(:,:,j),L1.M(cx(j)).S{n},'valid');
                end
                % Get the probability distribution.
                L2.M(i).P{n}=L2.N.tf(L2.M(i).C{n});
                
                if ~short
                    % Sample the probabilities to get the output dist
                    L2.M(i).S{n}=round(L2.M(i).P{n}-0.5+rand(size(L2.M(i).P{n})));
                end
                
                % Now find Gradient
                for j=1:length(cx) % For previous map that it's connected to
                    L2.M(i).G{n}(:,:,j)=filter2(L2.M(i).P{n},L1.M(i).S{n},'valid');
                end
                                
            end
            
        end
        
        function backwardPass(L1,L2)
            if nargin<3, n=1; end
            
            % Backward Pass
            for i=1:length(L1.M) % For each map...
                
                % Get inter-map connections, find size of filter.
                cx=find(L2.cnx(:,i));
                fwid=floor([size(L2.M(i).W,1) size(L2.M(i).W,2)]/2);
                
                % Reset current Current map.
                L1.M(i).C{n}(:)=L1.M(i).B(:);
                
                % Boundary pixels will just be the same as last tim.
                L1.M(i).S{n}(1:fwid,end-fwid,:)=L1.M(i).S{1}(1:fwid,end-fwid,:);
                L1.M(i).S{n}(:,1:fwid,end-fwid)=L1.M(i).S{1}(:,1:fwid,end-fwid);
                
                % Define center pixels on first layer.
                for j=1:length(cx) % For previous map that it's connected to
                    L1.M(i).C{n}(fwid+1:end-fwid,fwid+1:end-fwid)=L1.M(i).C{2}(fwid+1:end-fwid,fwid+1:end-fwid)+conv2(L2.M(cx(j)).S{1},L2.M(cx(j)).W(:,:,i),'same');
                end
                
                % Calculate probabilities and sample
                L1.M(i).P{1}=L2.N.tf(L12.M(i).C);
                L2.M(i).S{1}=round(L2.M(i).P-0.5+rand);

            end
            
            
            
        end
        
        
        function learnSomething(L2)
            % Learn the weights from a history of gradient calculation.
            
            for j=1:length(L2.M)
                L2.M(j).W=L2.M(j).W+A.N.eta*(L2.M(j).G{end}-L2.M(j).G{1});
            end
            
        end
        
        
        
        
    end
    
    
end





