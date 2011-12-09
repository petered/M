classdef ShowMeTheNumbhas < handle
    
    properties
        
        imageFile;
        labelFile;
        
        N=10;
        
        buffer=0;
                
        rTrans=0; % Random translation
        rScale=1; % Random scale change
        rRot=0;   % Random rotation        
        
        labEncoding='1off';
        
        
        IM;
        
        IMflat; % Image with pixels concatenated
        
        lab;
        teacher;
        
        ixtr;
        ixts;   
        
        trainfrac=0.75;
        
        
    end
    
    methods % Set, Get and Virtual properties
        
        function set.labEncoding(A,type)
            A.labEncoding=type;
            A.teacher=[];
        end
        
        function IMflat=get.IMflat(A)
            IMflat=reshape(A.IM,size(A.IM,1)*size(A.IM,2),[]);            
        end
            
        function set.lab(A,lab)
            
            A.lab=lab;
            A.teacher=[]; %#ok<*MCSUP>
                        
        end
        
        function t=get.teacher(A)
            if isempty(A.teacher)
                A.teacher=A.lab2teach(A.lab,A.labEncoding);
            end
            t=A.teacher;
        end
        
        function D=subSet(A,ix)
            D=A.IMflat(:,ix);
%             sampdim=ndims(A.IMflat);
%             switch sampdim
%                 case 2
%                     D=A.IM(:,ix);
%                 case 3
%                     D=A.IM(:,:,ix);
%                 otherwise
%                     error('Laziness.  Just fix it');
%             end
        end
        
        function D=trainIM(A)
            D=A.subSet(A.ixtr);                
        end
        
        function D=testIM(A)
            D=A.subSet(A.ixts);
        end
        
        function D=trainLab(A)
            D=A.lab(A.ixtr);                
        end
        
        function D=testLab(A)
            D=A.lab(A.ixts);
        end
        
        function D=trainTeach(A)
            D=A.teacher(:,A.ixtr);            
        end
        
        function D=testTeach(A)
            D=A.teacher(:,A.ixts);    
        end
                
        function set.trainfrac(A,f)
        	assert(~isempty(A.IM),'No Images yet... can''t define test/training set');
            nn=A.nim;
            A.ixtr=1:floor(nn*f);
            A.ixts=floor(nn*f)+1:nn;
            
        end
        
        function sz=imsize(A)
            sz=[size(A.IM,1) size(A.IM,2)];
        end
        
        function sz=nim(A)
            sz=size(A.IM,ndims(A.IM));
        end
        
        
    end
    
    methods 
        
        function [IM lab]=get(A)
            
%             if ~exist('flatten','var')||isempty(flatten), flatten=false; end
%             if ~exist('subsampling','var'), subsampling=[]; end
            
            fprintf('Reading Images... ');
            IM=lowlevelreading(A.imageFile,A.N);
            disp Done;
            
                      
            lab=lowlevelreading(A.labelFile,A.N);
            
%             if flatten
%                 IM=reshape(IM,size(IM,1)*size(IM,2),[]);
%             end
            
            A.IM=IM;
            A.lab=lab;
        end
        
        function applyTransforms(A)
            fprintf('Applying Image Transforms... ');
            IM_=padarray(A.IM,[A.buffer A.buffer]);
            IM_=shakeitup(IM_,'trans',A.rTrans,'scale',A.rScale,'rot',A.rRot);
            A.IM=IM_;
            disp Done;
        end
        
        function play(A)
            
            hF=figure(ceil(rand*1000000));
            colormap gray;
            
            for i=1:size(A.IM,3)
                imagesc(A.IM(:,:,i));
                if ~ishghandle(hF), return; end
                drawnow;
                pause(.2);
            end
            
        end
        
        function V=vec(A)
            V=reshape(A.IM,[],size(A.IM,3))';
        end
        
        function IM=vec2im(A,V)
            IM=reshape(V,size(A.IM,1),size(A.IM,2),[]);            
        end
        
    end
    
    methods (Static)
        
        function teach=lab2teach(lab,encoding)
            % Convert a vector of labels to a teacher
            
            if ~exist('encoding','var'), encoding='1off'; end
            
            [un,~,n]=unique(lab);
            teach=zeros(length(un),length(lab));
            
            switch encoding
                case '1off'
                    locs=sub2ind(size(teach),n,1:length(lab));
                    teach(locs)=1;
                case {'bin','rand'}
                    nel=ceil(log2(length(un)));
                    num=2^nel;
                    if strcmp(encoding,'randbin')
                        code=randperm(num); code=code(1:length(un));
                    else
                        code=0:length(un)-1;
                    end
                    q=quantizer('mode','ufixed',[nel,0]);
                    teach=num2bin(q,code(n))'=='1';
                otherwise
                    error('"%s" is not a recognised encoding',encoding);
            end
        end
        
        
    end
    
end