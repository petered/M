function lims=quickclip(mat,fraction,nSamples)
% Quick estimate of clipping limits.  Hopefully matlab know to pass mat by
% reference, because the whole thing is to save time.
% 
% mat is the data matrix.  Doesn't mattter what dims.
% fraction (optional) is the clipping fraction.  Default is 0.01.  
% nSamples(optional) is the number of samples to take for clipping.
% Default is 10000;
% eg. caxis(quickclip(images,0.01));

if ~exist('fraction','var'), fraction=0.001; end
if ~exist('nSamples','var'), nSamples=10000; end

if iscell(mat)
    a=cellfun(@(x)x(ceil(rand*numel(mat{1}))),mat(ceil(rand(1,nSamples))));
else
    a=mat(ceil(rand(1,nSamples)*numel(mat)));
end

a=sort(a(~isnan(a)));
nSamples=numel(a);

lims=a(ceil((nSamples-1)*[fraction 1-fraction])+1);



end