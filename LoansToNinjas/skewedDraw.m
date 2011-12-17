function varargout=skewedDraw(mu,sig,N,c,skew)
    % Draw points from a multivariate normal distribution
    %
    % x=skewedDraw(5,2,1000,[],true);
    % [x y]=skewedDraw(mu,sig,N,c,skew)
    
    if ~exist('skew','var'), skew=false; end
    
    sig=sig(:);
    
    Sig=diag(sig.^2);
    
    if ~isempty(c)
        [g1,g2]=meshgrid(1:length(mu));

        ix1=g1>g2;

        covs=c(:).*sig(g1(ix1)).*sig(g2(ix1));
        Sig(g1>g2)=covs;
        Sig(g1<g2)=covs;
    end
    
    assert(all(eig(Sig)>0),'The correlations you''ve chosen result in a non-positive-semidefinite covarance matrix.  Basically, they don''t work');
          
    X=mvnrnd(mu,Sig,N);
    
    if skew
        X=X.^2;
        X=bsxfun(@times,X,mu(:)'./mean(X));
    end
    
    
    
%     if nargout>1
        varargout=mat2cell(X,size(X,1),ones(size(X,2),1));
%     end
       
        
    
    
end