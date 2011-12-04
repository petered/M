function [s ix]=randss(x,nS,replacement,sorted)
% Random subsample of array x.
% nS - number of points to sample
% replacement - whether it's taken with replacement (default true)
% sorted - whether to sort the sample points. (default false)

if ~exist('replacement','var'), replacement=true; end
if ~exist('sorted','var'), sorted=false; end

if replacement
    ix=ceil(rand(1,prod(nS))*numel(x));    
else
    ix=randperm(numel(x)); % slow and lazy
    ix=ix(1:prod(nS));
end

if sorted,
    ix=sort(ix);
end

s=x(ix);

s=reshape(s,nS);


end