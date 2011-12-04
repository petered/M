classdef NetLister < handle
    % This'll Generate a text file to be read into the java code to build
    % the network.
    
    
    properties
        
        F;  % Cell array of S1 filters, indexed by scale, orientation
                
        L=struct('M',{},'name',{}); % Structure defining layers;
        
        FilterEdges=7:2:29;
        FilterAngles=0:45:179.9;
        
        
        
        % Layer-specific parameters
        
        
        s1Spacing=1; % Sampling density of filters
        
        c1Pool=9; % Note-we should come up with a band-wise definition
        c1Bands=[1 1 2 2 2 3 3 3 4 4 4 4]; % Must match length of FilterEdges
        c1Overlap=3;
        
        s2Edge=2; % No choice at the moment.
        
                
    end
    
    methods
        
        function makenet(A)
            
            % From the structure "L", generate a text file
            
            
            
            
        end
        

        function simple(A,dim)
            % Make a simple perceptron net, train it on the cross/X.
            
            im1=A.generationX(dim,[64 64],[120 20],0);   im1=im1-mean(im1(:));  im1=im1/norm(im1(:));
            im2=A.generationX(dim,[64 64],[120 20],45);  im2=im2-mean(im2(:));  im2=im2/norm(im2(:));
            
            % Just set weight vector to be the templates.
            L_(1).w=[im1(:)';im2(:)'];
            L_(1).b=[.5 .5];
            
            
%             L_(1).b=zeros([dim,1]);  % Doesn't matter for input layer.
%                         
%             % 
%             
%             L_(2).w=[];
%             L_(2).b=[.5 .5];
                        
            
            
            
            A.L=L_;
            
        end
        
        
        
        function look(A,im)
            % Look at an image
            
            A.L(1).name=inputname(2);
            A.L(2).name='S1';
            A.L(3).name='C1';
            A.L(4).name='S2';
            A.L(5).name='C2';
            
            A.L(1).M=im;
            A.L(2).M=A.im_s1(im,A.F,A.s1Spacing);
            A.L(3).M=A.s1_c1(A.L(2).M,A.c1Pool,A.c1Bands,A.c1Overlap);
            A.L(4).M=A.c1_s2(A.L(3).M,A.s2Edge);
            A.L(5).M=A.s2_c2(A.L(4).M);           
            
            
        end
        
        function view(A)
            
            h=Hview;
            
            set(h.popList,'string',{A.L.name},'callback',@(e,s)newLayer);
            
            
            bandRange=1;
            oriRange=1;
            
            band=1;
            ori=1;
            
            hL=[];
            imtit='';
            ix=1;
%             subplot(h.axControl);
%             imagesc(0);
                        
            function newLayer
               
               ix=get(h.popList,'value');
               
               % Make sure indeces are valid
               bandRange=1:size(A.L(ix).M,3);
               oriRange=1:size(A.L(ix).M,4);
               [xxx,band]=min(abs(bandRange-band));
               [xxx,ori]=min(abs(oriRange-ori));
               newIX([band ori]);
               
               % Set Up Scale/Orientation Selector
               subplot(h.axControl);
               [xx yy]=meshgrid(bandRange,oriRange);
               hI=imagesc(xx+yy);
               set(hI,'hittest','off');
               set(h.axControl,'ButtonDownFcn',@(e,s)newIX);
               set(gca,'ydir','normal');
               switch ix
                   case 2
                       xlab= 'scale';
                       ylab= 'orientation';
                       imtit=sprintf('%s: %s: %g, %s: %g',A.L(ix).name,xlab,A.FilterEdges(band),ylab,A.FilterAngles(ori));
                   case 3
                       xlab= 'scale-band';
                       ylab= 'orientation';
                       imtit=sprintf('%s: %s: %g, %s: %g',A.L(ix).name,xlab,band,ylab,A.FilterAngles(ori));
                   case 4
                       xlab= 'scale-band';
                       ylab= 'orientation combo';
                       imtit=sprintf('%s: %s: %g, %s: %g',A.L(ix).name,xlab,band,ylab,ori);
                   case 5
                       xlab='';
                       ylab= 'orientation combo';
                       imtit=sprintf('%s: %s: %g',A.L(ix).name,ylab,ori);
                   otherwise
                       xlab='';
                       ylab='';
                       imtit=A.L(ix).name;
                       
               end
               xlabel (xlab);
               ylabel (ylab);
               
               replot;
               
            end
            
            function replot
               ix=get(h.popList,'value');
               subplot(h.axIm);
               imagesc(A.L(ix).M(:,:,band,ori),quickclip(A.L(ix).M));
               title(imtit);
               colormap bone;
               
               subplot(h.axFilt)
               if ix==2, % S1 layer
                   imagesc(A.F{band,ori});
               else
                   cla;
               end
               
               
            end
                        
            function newIX(force)
                
                subplot(h.axControl);
                if ~exist('force','var')
                    P=get(gca,'CurrentPoint');
                    x=P(1,1);
                    y=P(1,2);

                    [xxx,band]=min(abs(bandRange-x));
                    [xxx,ori]=min(abs(oriRange-y));
                else
                   band=force(1);
                   ori=force(2);
                end
                    
                
                
                delete(hL(ishandle(hL)));
                hL=addline([band ori],'vh','color','r');
                set(hL,'hittest','off');
                
                if ~exist('force','var')
                    replot;
                end
            end
            
            
            
        end
         
        function F=makefilters(A)
            
            F=A.gaborfilters(A.FilterEdges,A.FilterAngles);
            
        end
        
        function F=get.F(A)
            if isempty(A.F)
                F=A.makefilters;
                A.F=F;
            else
                F=A.F;
            end
        end
        
        function [space class IM]=shapeproj(A,dim,N)
            % Runs a series of shapes through Hmax and returns the
            % projections onto the output layer.  Can be handy if you want
            % to determine the separability of the points.
            
            width=length(A.FilterAngles).^(A.s2Edge^2);
            
            [IM class]=A.randomShapes(dim,N);
            
            space=nan(N,width);
            fprintf('%g images.  Processing #..',N);
            for i=1:N
                fprintf('%g..',i);
                A.look(IM(:,:,i));
                space(i,:)=reshape(A.L(5).M,1,[]);                
            end
            disp Done
                        
        end
        
        
    end
    
    methods (Static) % Hmax Functions
        
        function F=gaborfilters(sizes,angles)
            % Generates cell array of gaussian filters.
            %
            % sizes is a length-N vector of filter sizes.
            %
            % angles is a length(M) vector of angles
            %
            
                                    
            F=cell(length(sizes),length(angles));
            for i=1:length(sizes)
                for j=1:length(angles)
                    F{i,j}=NetLister.rotgabor(sizes(i),angles(j));
                end
            end
            
        end
                
        function z=rotgabor(edge,angle,stretch)
            
            % Defaults
            range=1.5;
            if nargin<3, stretch=3; end
            
            % Setup transforms
            range=linspace(-range,range,edge);
            [x y]=meshgrid(range,range);
            R=[cosd(angle) -sind(angle); sind(angle) cosd(angle)];
            
            % First transform
            X=R*[x(:)'; y(:)'];
            C=[1 0; 0 stretch];

            % Then gaussify
            z=reshape(X(2,:).*exp(-sum(X.*(C*X))),size(x));
            
            % Center and normalize
            z(:)=z(:)-mean(z(:));
            z(:)=z(:)./sum(z(:).^2);
                        
        end
        
        function showFilters(F)
            
            s=size(F);
            for i=1:s(1)
               for j=1:s(2)
                   subplot(s(1),s(2),(i-1)*s(2)+j);
                   imagesc(F{i,j});
               end
            end
        end
        
        function s1=im_s1(im,F,spacing)
            % Given image and filter-set, compute layer s1.
            % 
            % spacing defines how widely to space the kernels.
            
            if ~exist('spacing','var'), spacing=1; end;
                        
            sF=size(F);
            
            s1=nan([ceil(size(im)/spacing) sF]);
            
            for i=1:sF(1) % For each scale
                imss=convn(im.^2,ones(size(F{i,1})),'same');
                
                for j=1:sF(2) % For each orientation
                    s1(:,:,i,j)=convn(im,F{i,j},'same')./imss;
                end
            end
                        
            
            if spacing~=1,
                % Inefficient I know but who cares.
                s1=s1(1:spacing:end,1:spacing:end,:,:);                
            end
            
        end
        
        function c1=s1_c1(s1,pool,bandID,overlap)
            % s1 is layer s1
            % pool is how many pixels to pool over
            % bandID is the mapping from scale to band (eg [1 1 1 2 2 3 3 ])
            
            X=abs(s1);
            
            % Max over scales within a band
            X=squeezecond(X,3,bandID,@max);
            sz=size(X);
            
            jump=pool-overlap;
            
            width=ceil((sz(1:2)-pool)/jump);
            
            % Build it.
            c1=nan([width sz(3:4)]);
            ixlist=@(ix)(ix-1)*jump+1:(ix-1)*jump+pool;
            for i=1:width(1)
                for j=1:width(2)
                    c1(i,j,:,:)=max(max(X(ixlist(i),ixlist(j),:,:),[],1),[],2);
                end
            end
            
        end
        
        function s2=c1_s2(c1,edge)
            % Edge is the edge of the box.  Normally 2.
            sz=size(c1);
                        
            % Get indeces defining all orientation combinations
            combos=dec2base(0:sz(4)^(edge^2)-1,sz(4));
            cc=arrayfun(@(c)str2double(c),combos)+1;
            
            % Make boxes
            if edge~=2, error('We don''t have this working for other edge sizes than 2 yet'); end
            foo=@(x,y,z,t)exp(-(x+y+z+t-4).^2/2);
            s2=foo( c1(1:2:end , 1:2:end, : , cc(:,1)) , ...
                    c1(1:2:end , 2:2:end, : , cc(:,2)) , ...
                    c1(2:2:end , 1:2:end, : , cc(:,3)) , ...
                    c1(2:2:end , 2:2:end, : , cc(:,4)) );
                        
            
        end
        
        function c2=s2_c2(s2)
            
            c2=reshape(s2,[],1,1,size(s2,4));
            c2=max(c2,[],1);
            
        end
        
    end
    
    methods (Static) % Input patter generators        
        
        function [im class]=randomShapes(dims,N)
            % This class will make N random shape images
            
            if length(dims)==1, dims=[dims dims]; end
            
            % Make the circles
            Ncr=floor(N/2);
            locs=(.2+.6*rand(Ncr,2)).*repmat(dims,[Ncr 1]);
%             locs=repmat(dims/2,[Ncr 1]);
            diams=rand(Ncr,2)*min(dims)/4+10;
            IMcr=NetLister.circlegen(dims,locs,diams);
            
            % Make the squares
            Nsq=ceil(N/2);
            locs=(.2+.6*rand(Ncr,2)).*repmat(dims,[Nsq 1]);
%             locs=repmat(dims/2,[Ncr 1]);
            edgelens=rand(Nsq,2)*min(dims)/4+10;
            angles=rand(Nsq,1)*360;  % yeah whatever, I know.
            IMsq=NetLister.squaregen(dims,locs,edgelens,angles);
            
            % Put 'em together
            im=cat(3,IMcr,IMsq);
            class=[zeros(Ncr,1);ones(Nsq,1)];
            
            % Shuffle them just for fun
            p=randperm(N);
            im=im(:,:,p);
            class=class(p);
                       
            
        end
        
        function im=generationX(dims,locs,edgelens,angles)
            % Generate an X
            
            im=NetLister.squaregen(dims,locs,edgelens,angles);
            im=im | NetLister.squaregen(dims,locs,edgelens,angles+90);
            
            
        end
        
        function im=circlegen(dims,locs,diams)
            % Generate images of circles.
            
            % Setup crap
            if length(dims)==1, dims=[dims dims]; end
            N=max(size(locs,1),length(diams));
            if size(locs,1)==1, locs=repmat(locs,[N 1]); 
            elseif size(diams,1)==N, diams=repmat(diams,[N 1]); 
            end
            radii2=(diams/2).^2;
                        
            % Generate images
            [x y]=meshgrid(1:dims(1),1:dims(2));
            im=false([dims N]);
            for i=1:N
                im(:,:,i)=(x-locs(i,1)).^2+(y-locs(i,2)).^2<radii2(i);
            end
            
            
            
        end
        
        function im=squaregen(dims,locs,edgelens,angles)
            % Generate images of squares
            
            % Setup crap
            if length(dims)==1, dims=[dims dims]; end
            N=max(size(locs,1),size(edgelens,1));
            if size(locs,1)==1, locs=repmat(locs,[N 1]); 
            elseif size(edgelens,1)==N, edgelens=repmat(edgelens,[N 1]); 
            end
            if size(edgelens(2))==1, edgelens=repmat(edgelens,[1 2]); end
            
            
            % Generate images
            [x y]=meshgrid(1:dims(1),1:dims(2));
            im=false([dims N]);
            for i=1:N
                
                [xt yt]=coordtrans(x-locs(i,1),y-locs(i,2),angles(i));
                
                im(:,:,i)=(abs(xt)-edgelens(i,1)/2) < 0 & (abs(yt)-edgelens(i,2)/2 < 0);
                
            end
            
            
            
            function [xt,yt]=coordtrans(x,y,ang)
                
                if ang==0
                    xt=x;
                    yt=y;
                    return;
                end
                
                R=[cosd(ang) -sind(ang);sind(ang) cosd(ang)];
                
                X=R*[x(:)';y(:)'];
                
                xt=reshape(X(1,:),size(x));
                yt=reshape(X(2,:),size(x));
                
            end
            
        end
                
        function standardScript
            
            A=NetLister;
            
            N=500;
            dim=128;
            ixtrain=1:350; 
            ixtest=351:500;
            nComp=5;
            
            
                    nN=nN;
            % Make an input
            [IM class]=A.randomShapes(dim,N);
            
            % Make an output space
            width=length(A.FilterAngles).^(A.s2Edge^2);
            space=nan(N,width);
            fprintf('%g images.  Processing #..',N);
            for i=1:N
                fprintf('%g..',i);
                A.look(IM(:,:,i));
                space(i,:)=reshape(A.L(5).M,1,[]);                
            end
            disp Done
            
            % PCA
            [xxx,PC]=princomp(space(ixtrain,:),'econ');
            cl=classify(PC(ixtest,1:nComp),PC(ixtrain,1:nComp),class(ixtrain));
            
            fprintf('Score is: %g%%\n',100*nnz(cl==class(ixtest))/length(cl));
            
            
        end
        
    end
    
    methods (Static) % Text-Format Network Generators
        
        function textInfo
            % These functions generate text-file descriptions of neural
            % networks.  The purpose of these text files is to describe a
            % neural network as a series of node-to-node connections that can
            % be read into the java program.  An example showing the format of
            % the text file is shown here:
            %
            % ------------------------
            % Name: ExampleNet
            % Notes: Generated 04-May-2011 16:54:01
            % #Units: 16386
            %
            % Unit 0
            % #Connections: 5
            % W: 0.565 -0.121 0.8846 0.241 0.221
            % B: 0.3
            % C: 2 3 5 8 7
            %
            % Unit 1
            % #Connections: 3
            % W: -0.565 0.121 -0.889
            % B: -0.1
            % C: 5 6 7
            %
            % ....
            % ------------------------
            %
            % The W-vector associated with Unit 1 specifies the weights of
            % connections FROM unit 1.  Usually when specifying NN's, weights
            % are associated with the receiving unit.  For AER systems though,
            % it must be done the other way.
            %
            % The B is just the bias of a unit.  It will be interpreted into
            % some firing threshold in the AER system.
            % 
            % The C-vector is the list of units that the neuron projects to.  
            % It should be the same length as, Generated:  the W-vector.
            %
            % Future implemenations should take advantage of shared weights for
            % convolutional networks.
        end
                
        function txt=snet2txt(L,name,notes,scrapzeros)
            % Write a simple Neural Net to text format
            %
            % L is a structure array of layers.  Expect fields:
            %   w   - MxN matrix specifying connection between layers.
            %   b   - Length-M vector specify, Generated: ing bias values      
            %
            % L(1) is first hidden layer (out output in 1-layer net)
            % L(end) is output layer
            %
            % Scrapzeros will eliminate all weights with magnitudes less
            % than 1/scrapzeros of the average mag
            
            if ~exist('name','var'), name='Simple Net' ; end
            if ~exist('notes','var'), notes=['Generated ' datestr(now)]; end
            if ~exist('scrapzeros','var'), scrapzeros=0; end
                        
            k=0;
                        
            
            nUnits=sum(arrayfun(@(s)size(s.w,1),L))+size(L(1).w,2);
            
            fid=fopen([name '.txt'],'w');
            fprintf(fid,'Name: %s\nNotes: %s\n#Units: %g\n\n',name,notes,nUnits);
                        
            fprintf('Printing Network...\n');
            hw=waitbar(0,['Printing Network: "' name '"']);
            nNP=0; % Number of connections layed so far in previous layers
            for i=1:length(L)+1 % For each layer
                
                % Get number of neurons in layer
                if i<length(L)+1 % For all layers up to the last..
                    nN=size(L(i).w,2);
                    % Note: Could check consistency here.
                    
                    if ~scrapzeros, include=1:size(L(i).w,1); end
                    
                else             % For the last
                    nN=size(L(i-1).w,1);
                end
                
                
                
                
                % Print each neuron in layer
                for j=1:nN
                    
                    if scrapzeros && i<length(L)+1
                        temp=abs(L(i).w(:,j))';
                        include=find(temp>mean(temp)/scrapzeros);
                    end
                    
                    if i==1                 % Print the input layer
                        fprintf(fid,'Unit %g\n#Connections: %g\nW: %s\nB: %g\nC: %s\n\n',...
                            k,length(include),num2str(L(i).w(include,j)'),0,num2str(nN+include-1));                        
                    elseif i==length(L)+1   % Print the output layer
                        fprintf(fid,'Unit %g\n#Connections: %g\nW: %s\nB: %g\nC: %s\n\n',...
                            k,0,[],L(i-1).b(j),'out'); 
                    else                    % Print a hidden layer
                        fprintf(fid,'Unit %g\n#Connections: %g\nW: %s\nB: %g\nC: %s\n\n',...
                            k,length(include),num2str(L(i).w(include,j)'),L(i-1).b(j),num2str(nNP+nN+include-1));                        
                    end
                    
                    if ceil(100*k)>ceil(100*k-1),waitbar(k/nUnits,hw); end
                    k=k+1;
                end
                
                nNP=nNP+nN; % Increment connections from previous.
            end
            delete(hw);
            fprintf('Network-File "%s" Printed in "<a href="matlab: winopen(''%s'');">%s</a>"\n',[name '.txt'],regexprep(cd,'''',''''''),cd);
            
            fseek(fid,0,'bof');
            txt=fread(fid);
            fclose(fid);
            
                       
        end
                
        function cnet2text(dim,L)
            % Write a convolutional Neural Net to text format.
            %
            % Dim is the Y-by-X dimension of the input image
            % L is a structure arraw of layers.  Expect fields:
            %   w    - 2-d kernel operating on previous layer.  If w is a
            %          cell array of length N, N maps will be built, and
            %          map i will have kernel w{i}
            %        - 
            %   type - Operation performed by layer (eg 'conv','max').
            %          This will define how the operation will be
            %          implemented.
            %   
            % The text file will first contain a list of cells.  Each cell
            % will have an associated array of the cells it projects to,
            % and the weights with which this projection is made.
            %
            %
            
        end
            
        function mini2txt(layer,name,notes)
            
            if ~exist('name','var'), name='Mini-Net' ; end
            if ~exist('notes','var'), notes=['Generated ' datestr(now)]; end
            
            
            % Convert output of MiniTrainer.m into a network
            dim=[128 128];
            
            % Transform it into a simple network
%             LL=struct('w',{},'b',{});
            
            LL.w=nan([length(layer(2).map) prod(dim)]);
%             LL(1).b=zeros(prod(dim),1);
            for i=1:length(layer(2).map)
                temp=imresize(layer(2).map(i).W{1},dim);     
                LL.w(i,:)=temp(:);
                LL.b(i)=layer(2).map(i).b;
            end
                        
            NetLister.snet2txt(LL,name,notes);
            
            
            
        end
                
        function FFnet2txt(oldL,name,notes,redim,scrapzeros)
            
            if ~exist('name','var')||isempty(name), name='MLP' ; end
            if ~exist('notes','var')||isempty(notes), notes=['Generated ' datestr(now)]; end
            if ~exist('redim','var'), redim=false ; end
            if ~exist('scrapzeros','var'), scrapzeros=0 ; end
            
            % Transform into structure with correct field names
            for i=1:length(oldL)
                L_(i)=struct(oldL(i));
            end
            
            for i=1:length(L_)
               L_(i).w =L_(i).W;
               L_(i).b =L_(i).B;
            end
            L_=rmfield(L_,{'W','B'});
            
            % Expand inputs to match retina dims
            if redim
                olddim=[sqrt(size(L_(1).w,2)) sqrt(size(L_(1).w,2)) ];
                if ~isequal(olddim,round(olddim)), error('Can''t find origninal image dimensions'); end
                dim=[128 128];            
                temp=reshape(L_(1).w',olddim(1),olddim(2),[]);
                temp=imresize(temp,dim);
                L_(1).w=reshape(temp,[],size(temp,3))';
            end
            
            % Print the transformed net.
            NetLister.snet2txt(L_,name,notes,scrapzeros);
            
            
        end
        
        function N=go
            
            N=NetLister;
            
            N.simple([128 128]);
            
            N.snet2txt(N.L);           
            
            
            
        end
            
            
            
        
        
    end
    
end