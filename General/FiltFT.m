function [x]=FiltFT(x,fc,fs,dim,type)

% A Filtering program for the people.  Enter your data your cutoff
% frequencies, your sampling rate, and (optionally) the dimension you'd
% like to filter along.  In exchange you get a matix of filtered values
% back.
% Example: y=FiltFT(x,[10 50],1000,2);

%% Get fist non-singletron dimension
if ~exist('dim','var')||isempty(dim) 
    dim=find(size(x)~=1,1); 
end

if ~exist('fs','var')||isempty(fs)
    fs=2; % Indicating that fc should be a fraction of Nyqist (1)    
end

if ~exist('type','var')
    switch numel(fc)
        case 1, type='lp';
        case 2, type='bp';
    end
end

%% Make Filter
X=fft(x,[],dim);
Mask=zeros(size(X,dim),1);

if numel(fc)==1,
    switch lower(type)
        case 'lp'
            f1=1;
            f2=(ceil(fc*size(X,dim)/fs));
        case 'hp'
            f1=(floor(fc(1)*size(X,dim)/fs))+1;
            f2=ceil(size(X,dim)/2);
        otherwise
            error 'Filter type does not match number of cutoffs.'
    end
elseif numel(fc)==2.
    f1=(floor(fc(1)*size(X,dim)/fs))+1;
    f2=(ceil(fc(2)*size(X,dim)/fs));
else
    error('You didn`t specify your filter properly!')
end
    
Mask(f1:f2)=1;
Mask(end-f2+1:end-f1+1)=1;


rep=NaN(1,ndims(x)-1);
for i=1:ndims(x)
    rep(i)=size(X,i);
end
rep(dim)=1;

Mask=permute(Mask,[2:dim 1 dim+1:ndims(X)]);
Mask=repmat(Mask,rep);


%% Go

x=real(ifft(X.*Mask,[],dim));


end