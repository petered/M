
function points=sampleFrom(D,n)
   % Draw samples from a probability distribution D.
   % D doesn't need to be normalized.
   % Samples will be returned as a size(n,d) matrix, where n is the
   % number of samples desired and d is the dimension of D

   sz=size(D);
   ix=randsample(numel(D),n,true,D(:));

   s=struct;
   s(length(sz)).a=[];

   [s.a]=ind2sub(sz,ix);

   points=cat(2,s.a);


end