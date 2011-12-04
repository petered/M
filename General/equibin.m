function [edges bin binner]=equibin(x,n)
% Given a vector x, assumed to be drawn from some distribution, define n
% bins (with n-1 edges), such that values fall roughly equally into these
% bins.  
%
% Outputs:
% .edges identifies the edges between the bins.
% .bin(i) identifies which bin x(i) belongs to.  x(i) belongs to bin i if
%   edges(i-1)<=x(i)<edges(i) (considering edges(0) to be -Inf and edges(n)
%   to be Inf.
% .binfun is a function that will bin any new vector x according to the
%   bins defined here.

% assert(isvector(x),'x must be a vector!');

if isempty(x)
    edges=nan(1,size(n-1));
    bin=[];
    binner=@binfun;
    return;
end

sz=size(x);

x=x(:);

y=sort(x);

dim=find(size(x)>1);

divix=linspace(1,length(y),n+1);

if size(y,1)>1, divix=divix'; end


divfrac=divix-floor(divix);

dival=y(floor(divix)).*(1-divfrac)+y(ceil(divix)).*divfrac;

edges=dival(2:end-1);



function b=binfun(x)
    [~,b]=histc(x,cat(dim,-Inf, edges, Inf));    
end

if nargout > 1    
    bin=binfun(x);    
    bin=reshape(bin,sz);
    if nargout >2
       binner=@binfun;
    end
end

end

