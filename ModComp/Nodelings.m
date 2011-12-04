classdef Nodelings < handle
    
    
    properties
        
        targ=struct;                
        count;
        
        loc;
        
        autoview=true;
                
    end
    
    methods
        
        function A=Nodelings
            import java.util.HashMap;
            A.targ=HashMap;            
        end
        
        function iter(A)
            
            cnts=zeros(size(A.count));
            
            for i=1:length(cnts)
                tar=A.gettarg(i,A.count(i));
                cnts(tar)=cnts(tar)+1;   
            end
            
            A.count=cnts;
            
            if A.autoview
                A.view;
            end
            
        end   
        
        function view(A)
            
            mx=max(A.count);
            cmap=hsv(mx+1);
            
            cla;
            hold on;
            
            for i=0:mx
               plot(A.loc(A.count==i,1),A.loc(A.count==i,2),'o','color',cmap(i+1,:),'MarkerFaceColor',cmap(i+1,:));
            end
            drawnow;
        end
                
        function settarg(A,ix,n,val)
%             A.targ(A.hash(ix,n))=val;
            A.targ.put(A.hash(ix,n),val);
        end
        
        function val=gettarg(A,ix,n)
%             if isfield(A.targ,A.hash(ix,n))
%                 val=A.targ.(A.hash(ix,n));
                val=A.targ.get(A.hash(ix,n));
%             else
%                 val=[];
%             end
            
%             try
%                 val=A.targ.(A.hash(ix,n));
%             catch ME
%                 if strcmp(ME.identifier,'MATLAB:nonExistentField');
%                     val=[];
%                 else
%                     rethrow(ME);
%                 end                
%             end
           
        end       
        
        
        
    end    
    
    methods (Static)

        function x=hash(n1,n2)
            x=sprintf('x%g_%g',n1,n2);
        end

    end
end