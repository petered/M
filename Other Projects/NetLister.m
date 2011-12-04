classdef NetLister < handle
    % This'll Generate a text file to be read into the java code to build
    % the network.
   
   
    properties
        L=struct('S',{}); % Structure defining layers;
       
       
    end
   
    methods
       
        function makenet
           
           
           
           
           
           
        end
       
       
       
       
       
    end
   
   
    methods (Static)
       
        function F=gaussfilters(sizes,angles,order)
            % Generates cell array of gaussian filters.
            %
            % sizes is an Nx2 matrix, where each row is the dimensions of a
            %   filter.
            % angles is a length(N) vector, where each element is the
            %   orientation (in degrees). 
            % order is a length(N) vector, determining, in the direction of
            %   the angle, which derivative of the gaussian to take.
           
           
            n=size(sizes,1);
            if ~exist('order','var'),
                order=2*ones(n,1);
            end
                       
           
           
           
            for i=1:size(sizes,1)
                [x y]=meshgrid((1:sizes(1))-sizes(1)/2+.5,(1:sizes(2))-sizes(2)/2+.5);

                
               
               
               
            end
           
           
           
        end
       
       
    end
   
   
   
end
