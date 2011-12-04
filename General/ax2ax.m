function ax2ax(hSource,hDest)
% Copy everything on one axes to another.
% Still doesn't do legend.  Don't know abouut colorbars, but hey its a
% start.

% Find children, copy non-text ones.
kids=allchild(hSource);
nontextkids=kids(~strcmp(get(kids,'type'),'text'));
copyobj(nontextkids,hDest);

% Axes Directions (may need to add other properties)
meth={'YDir','XLim','YLim'};
cellfun(@(m)set(hDest,m,get(hSource,m)),meth);

% Special treatment for text-children
figure(get(hDest,'parent'));
subplot(hDest)
xlabel(get(get(hSource,'xlabel'),'string'));
ylabel(get(get(hSource,'ylabel'),'string'));
title(get(get(hSource,'title'),'string'));

end