function hdest=figmerge(figs,dir)
% Create a figure and merge the axes in h.

if ~exist('dir','var'), dir='h'; end

hF=figure;
if isnumeric(dir)
    assert(numel(dir)==2,'dir, if numeric, must be a 2-el vector!');
    assert(prod(dir)>=length(figs),'Total number of subplots hast to be at least number of figures');
    
    hdest=arrayfun(@(i)subplot(dir(1),dir(2),i),1:length(figs));
    
else
    switch dir
        case 'h'
            hdest=arrayfun(@(i)subplot(1,length(figs),i),1:length(figs));
        case 'v'
            hdest=arrayfun(@(i)subplot(length(figs),1,i),1:length(figs));
        case 's'
            hdest=arrayfun(@(i)subplot(ceil(length(figs)/ceil(sqrt(length(figs)))),ceil(sqrt(length(figs))),i),1:length(figs));
        otherwise
            error 'Stop fucking with me'
    end
end

hsrc=nan(1,length(figs));
figure(hF);
for i=1:length(figs)
    hc=allchild(figs(i));
    hc=hc(strcmp(get(hc,'type'),'axes'));
    
    legends=arrayfun(@(x)isfield(get(x),'String'),hc);
    
    arrayfun(@(h)ax2ax(h,hdest(i)),hc(~legends));
    
    if any(legends)
        subplot(hdest(i));
        legend(get(hc(legends),'string'));
    end
    
end







end