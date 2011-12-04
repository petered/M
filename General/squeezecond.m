function varargout=squeezecond(data,dim,ix,funs)
% Ok, so the goal of this thing is to take the functions in funs, apply
% "sqeezing" functions (such as mean,max, etc) to them along a certain
% dimension, where these conditions are applied across conditions specified
% in ix.
%
% Input     Description                                 Default if empty
% data      Data Matrix                                 -
% dim       Dimension over which to do squeezing        -
% ix        Condition vector (length of size(data,dim)  ones(1,size(data,dim))
% funs      Cell array of functions to apply (or just function handle for one)
%
% varargout returns the squeezed matrixes for each squeezing condition in
% funs.
%
% Eg.
% Say data is a 3-D matrix where size(data) is [128 128 6].  Say this matrix
% represents a trialset with 6 trials consisting of 2 conditions being
% alternated 3 times;
% >> cond=[0 1 0 1 0 1];
% Then to find the mean over each condition, go
% >> meandat=squeezecond(data,3,cond,@mean);
% 
% meandat will be of size [128 128 2], where meandat(:,:,1) will represent
% the mean over condition 0 and meandat(:,:,2) will represent mean over
% condition 1.  In general, the order of the conditions returned will be
% that seen in unique(cond);
%
% Peter O'Connor
% peter.ed.oconnor .^at_. gmail %. com


if isempty(ix), ix=ones(1,size(data,dim)); end

ixs=unique(ix);

if ~exist('funs','var')
    funs={@mean};
elseif ~iscell(funs)
    funs={funs};
end

if length(ix)~=size(data,dim)
    error('The size of data along dimension-%g (%g) does not match the number of elements in vector "cond" (%g)',dim,size(data,dim),length(ix));
end

% Intitialize output matrices.
sz=size(data); sz(dim)=length(ixs);
for i=1:length(funs)
   varargout{i}=nan(sz); 
end

ixstring=[repmat(':,',[1 dim-1]) 'i' repmat(',:',[1 length(sz)-dim])];

for i=1:length(ixs)
    
    subdata=submatrix(data,ix==ixs(i),dim); %#ok<NASGU>
    
    for j=1:length(funs)
        
        % Note... improve later
%         if ischar(funs{j}), funs{j}=str2func(funs{j}); end
        
        
        
        
        % Get function syntax specs
        if ischar(funs{j}), funname=funs{j};
        else funname='other'; %funname=func2str(funs{j});
        end
        switch funname
            case {'mean','median','mode','size'}
                exp=['varargout{j}(' ixstring ')=feval(funs{j},subdata,dim);'];
            case {'var','std','min','max'}
                exp=['varargout{j}(' ixstring ')=feval(funs{j},subdata,[],dim);'];
            otherwise
                exp=['varargout{j}(' ixstring ')=feval(funs{j},subdata,dim);'];
        end
                
        eval(exp);
    end
end

varargout{end+1}=ixs;

end


function Y=submatrix(X,ix,dim) %#ok<INUSL>
    % Finally a way to get a submatrix
    sz=size(X);

    % Roundabout way but there's actually not function for this.
    inststr=['X(' repmat(':,',[1 dim-1]) 'ix' repmat(',:',[1 length(sz)-dim]) ');'];
    Y=eval(inststr);
end