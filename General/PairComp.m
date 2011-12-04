function P=PairComp
% Pairwise comparisons thing.  Takes in a timeseries matrix, applies
% pairwise comparisons between columns, spits out one or more cell
% arrays with the results. 
%
% So basically, this should be applicable to any function that normally
% exists in the form:
%
% [out1...outN]=foo(x,y,in1,...inN);   
%   where x,y are 1-d timeseries each of length nSamples
% 
% Say you want to compare 3 or more signals in this manner, but you're too
% goddamn lazy to make all the required loops.  Instead, you can now go:
% P=PairComp;
% [Out1...OutN]=P.foo(X,in1...inN)
%   where X is an array of size (nSamples x nChannels);
%   Outputs will now be nChannel x nChannel cell arrays, each element
%   containing the outputs from a pairwise comparison.
%
% Sometimes, foo(x,y) equals foo(y,x).  In this case, add the function to
% the symmetric list (to save computational time).  To add:
% reverse-symmetics
%
% author:
% Peter O'Connor
% poconn4 .at. gmail.com

% Add any function of above form to this list
fList={@xcorr,@xcov,@conv,@tscorr,@xcorrchunk};
fListSymmetric={@ttest,@ttest2};

for i=1:length(fList)
    P.(func2str(fList{i}))=@(varargin)PairThatShit(fList{i},varargin{:});
end

for i=1:length(fListSymmetric)
    P.(func2str(fListSymmetric{i}))=@(varargin)PairThatSymmetricShit(fListSymmetric{i},varargin{:});
end

end


function varargout=PairThatShit(func,ts,varargin)

    n=nargout;
    
    CA=cell(size(ts,2),size(ts,2),n);
    
    fprintf('Computing %s: \n',func2str(func));
    for i=1:size(ts,2)
        for j=1:size(ts,2)
            fprintf('  pair %g of %g\n',(i-1)*size(ts,2)+j,size(ts,2)^2);
            [CA{i,j,1:n}]=func(ts(:,i),ts(:,j),varargin{:});
        end
    end
    disp Done.
    
    varargout=cell(1,n);
    for i=1:n
        varargout{i}=CA(:,:,i);
    end

end


function varargout=PairThatSymmetricShit(func,ts,varargin)

    n=nargout;
    
    CA=cell(size(ts,2),size(ts,2),n);
    
    fprintf('Computing %s: \n',func2str(func));
    for i=1:size(ts,2)
        for j=1:size(ts,2)
            fprintf('  pair %g of %g\n',(i-1)*size(ts,2)+j,(size(ts,2)+1)*size(ts,2)/2);
            [CA{i,j,1:n}]=func(ts(:,i),ts(:,j),varargin{:});
            CA(j,i,:)=CA(i,j,:);
        end
    end
    disp Done.
    
    varargout=cell(1,n);
    for i=1:n
        varargout{i}=CA(:,:,i);
    end

end


