
function H = JointEntropy(X)

% Sort to get identical records together
X = sortrows(X);

% Find elemental differences from predecessors
DeltaRow = (X(2:end,:) ~= X(1:end-1,:));

% Summarize by record
Delta = [1; any(DeltaRow')'];

% Generate vector symbol indices
VectorX = cumsum(Delta);

% Calculate entropy the usual way on the vector symbols
H = Entropy(VectorX);


% God bless Claude Shannon.

% EOF

% 
% 
% 
% 
% 
% function v = JointEntropy(x, y)
% % Joint entropy of two vectors
% % Written by Mo Chen (mochen@ie.cuhk.edu.hk). March 2009.
% assert(length(x) == length(y), 'x and y must be the same length');
% 
% x = x(:);
% y = y(:);
% 
% n = length(x);
% 
% x_unique = unique(x);
% y_unique = unique(y);
% 
% % check the integrity of y
% if length(x_unique) ~= length(y_unique)
%     error('number of states of inputs are not equal.');
% end;
% 
% c = length(x_unique);
% 
% % distribution of y and x
% Ml = double(repmat(x,1,c) == repmat(x_unique',n,1));
% Mr = double(repmat(y,1,c) == repmat(y_unique',n,1));
% 
% M = Ml'*Mr/n;
% v = -sum( M(:) .* log2( M(:) + eps ) );
% 

