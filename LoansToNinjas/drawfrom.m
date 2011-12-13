function X=drawfrom(dist,N)

cdf=cumsum(dist);

r=cdf(end)*rand(1,N);

[~,X]=histc(r,[0 cdf]);

% X=X(1:end-1);

end