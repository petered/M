classdef FFnetClass <handle
    
    properties
       
        L;  % Array of layer objects
        
        rate;
        
        decay;
        
        O;
        
        batch=100;  % SIze of batches used for training
        
    end
  
    
    methods
        
        function A=FFnetClass(sizes)
            
            A.L=LayerClass(sizes(1),sizes(2));
            
            for i=2:length(sizes)-1
                A.L(i)=LayerClass(sizes(i),sizes(i+1));
                          
            end
            
            
        end
        
        function out=getoutput(A,input)
            
            A.L(1).getoutput(input);
            
            for i=2:length(A.L)
                A.L(i).getoutput(A.L(i-1).O);
            end
            
            A.O=A.L(end).O;            
            
            out=A.O;
        end
        
        function backprop(A,targets)
            
            A.L(end).E=(A.O-targets);
            
            for i=length(A.L)-1:-1:1
                A.L(i).backprop(A.L(i+1).E,A.L(i+1).W);
            end
                        
        end
                
        function getdW(A,inputs)
            A.L(1).getdW(inputs);
            
            for i=2:length(A.L)
               A.L(i).getdW(A.L(i-1).O); 
            end
            
        end
                
        function reweigh(A)
            
            for i=1:length(A.L)
                A.L(i).reweigh;
            end
            
        end
        
        function set.rate(A,rate)
            for i=1:length(A.L)
                A.L(i).rate=rate;
            end
        end
        
        function set.decay(A,decay)
            for i=1:length(A.L)
                A.L(i).decay=decay;
            end
        end
        
        function [grade err]=testnet(A,input, tar)
            % Input,target indexed as (dim,sample)
            
            out=A.getoutput(input);
            
            err=mean(sum((tar-A.O).^2,1));
            
            grade=A.success(out,tar);
                        
        end
                
        function success=trainround(A,in,tar)
            
            out=A.getoutput(in);
            
            success=A.success(out,tar);

            A.backprop(tar);

            A.getdW(in);

            A.reweigh;
            
        end
                
        function batchTrain(A,in,teacher,epochs)
            
            if size(teacher,2)~=size(in,2);
                error('The number of samples in the training set, %g, does not match the number of labels, %g.',size(in,2),size(teacher,2));
            end
            
            if size(teacher,1)~=size(A.L(end).W,1);
                error('The number of elements in each column (sample) of the teacher matrix, %g, does not match the number of outputs, %g.',size(teacher,1),size(A.L(end).W,1));
            end
            
            if ~exist('epochs','var'); epochs=1; end
            
            nbatch=ceil(size(in,2)/A.batch);
            fprintf('Training network (supervised): %g epochs of %g batches\n',epochs,nbatch);
                        
            for ep=1:epochs
                fprintf('  Epoch %g:  ',ep);
                k=1;
                for ba=1:nbatch-1
                    success=A.trainround(in(:,k:k+A.batch-1),teacher(:,k:k+A.batch-1));  
                    fprintf('%g:%g%%..',ba,success*100);
                    k=k+A.batch;
                end
                fprintf('%g..',nbatch);
                A.trainround(in(:,k:end),teacher(:,k:end));     
                disp Done                
            end
            
        end
        
    end
    
    
    methods (Static)
        
        function success=success(guess,teacher)
            % guess ad teacher are noutput x nsamples matrices
            % suc is the fraction of the time that the max guess was the
            % same at the max of the teacher.
            
            [garb,guess]=max(guess,[],1);
            [garb,truth]=max(teacher,[],1);
            
            success=nnz(guess==truth)/length(guess);
            
        end
        
    end
    
    
    
end