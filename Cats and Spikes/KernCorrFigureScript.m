
% figs=[2 5 1 7];

figs=[6 7 3 4];

figmerge(figs,'v')

hax=[];
for i=1:length(figs)
    hax(i)=subplot(length(figs),1,i);
    grid on;
    set(gca,'xscale','log','xlim',[0,100])
    if i<length(figs)
        set(gca,'xticklabels',{});
        xlabel '';
        ylabel '';
    else 
        ylabel 'Relative Correlation';
    end
    set(gca,'position',get(gca,'position').*[1 1 1 1.3]);
    
end
linkaxes(hax);

