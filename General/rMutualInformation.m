function [IM sig]=rMutualInformation(X,divs,nStraps)
    % Returns the relative mutual information of a the set of column
    % vectors in X.  
    %
    % The 'relative' just means divided by the average MI of a series of
    % randomly shiffled versions.  The randomness means this function will
    % not have the exact same output each time, but the diff should be
    % small for sufficient sample-lengths.
    %
    % So anything consistently above 1 is informative.
    %
    % IM will be a symmetric square matrix of rMI between each vector pair.


    if ~exist('divs','var'), divs=0; end
    if nargin<3,nStraps=5; end

    if divs
        [~,X]=equibin(X,divs);
    else 
        divs=length(unique(X(:)));
    end
    
    [IM sig]=deal(nan(size(X,2)));
    for i=1:size(X,2)
        for j=1:i
            
            IM(i,j)=MutualInformation(X(:,i),X(:,j));
            IM(j,i)=IM(i,j);
            
            if nargout>1
                J=nan(1,nStraps);
                for k=1:nStraps
                    J(k)=MutualInformation(X(:,i),X(randperm(end),j));
                end
                sig(i,j)=IM(i,j)/mean(J);
                sig(j,i)=sig(i,j);
            end
            
        end
    end
    
    % Normalize (Note: innacurate if bins not equally split!')
    IM=IM/log2(divs);

end