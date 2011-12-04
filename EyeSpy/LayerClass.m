classdef LayerClass < handle
    % Layer of neurons
    
    
    properties
        
        rate=0.05; % Learning rate parameter
        
        decay=0.001;
        
        U;  % Current: Used in backpropagation
        
        O;  % Output: Feeds input of next layer
        
        E;  % Error vector (sent back)
        
        B;  % Bias: Equivalent to negative of threshold
        dB;
        
        W;  % Weight matrix (NxM, where N is length Output, M is length (input)
        dW; % Weight changes
        
        % Transfer Function and derivative
        f=@(x)logsig(x);
        df=@(I) 1./(2+exp(I)+exp(-I));
        
    end
    
    
    methods
        
        function A=LayerClass(nIn,nOut)
           
            A.W=randn(nOut,nIn);
            A.B=randn(nOut,1);
            
        end
        
        
        
        function getoutput(A,input)
            
                        
            A.U=A.W*input+repmat(A.B,[1 size(input,2)]);
            
            A.O=A.f(A.U);   
            
        end
        
        function backprop(A,error,Wplus)
            
            % Propagate error back;
            %A.E=(Wplus'*error).*A.df(A.U);
            A.E=(Wplus'*error);
        end
            
        
        function getdW(A,input)
            
            % Find weight changes
            %A.dW=-A.rate*(A.E*input');
            A.dW=-A.rate*((A.E.*A.df(A.U))*input');
            
            
            % Note: somewhat questionable about the following step:
            A.dB=-mean(A.rate*A.E.*A.df(A.U),2);
            
        end
                   
        
        function reweigh(A)
           
            A.W=A.W+A.dW-A.decay*A.W;
            
            A.B=A.B+A.dB;
            
        end
        
        
    end
    
end