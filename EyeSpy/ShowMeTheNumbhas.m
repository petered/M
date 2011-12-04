classdef ShowMeTheNumbhas < handle
    
    properties
        
        imageFile;
        labelFile;
        
        
        N=10;
        
        buffer=0;
        
        rTrans=0; % Random translation
        rScale=1; % Random scale change
        rRot=0;   % Random rotation        
        
        IM;
        lab;
        
        
        
        
        
    end
    
    methods
        
        function [IM lab]=get(A)
            
            IM=lowlevelreading(A.imageFile,A.N);
            IM=padarray(IM,[A.buffer A.buffer]);
            IM=shakeitup(IM,'trans',A.rTrans,'scale',A.rScale,'rot',A.rRot);
            
            lab=lowlevelreading(A.labelFile,A.N);
            
            A.IM=IM;
            A.lab=lab;
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
    
end