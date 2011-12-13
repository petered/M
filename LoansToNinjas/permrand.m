function v=permrand(n,k)
% Because R2010 still has the clumsy randperm syntax.  See 2011
% documentation
%
% NOTE: This is inefficient when k is small and n is large.  Could be
% improved

if nargin<2
    k=length(n);
end

if length(n)>1 || k==1
    v=n(randperm(length(n)));
else
    v=randperm(n);
end

v=v(1:k);