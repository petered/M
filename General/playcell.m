function playcell(mov,clips)
    if ~exist('clips','var'), clips=quickclip(mov); end
    figure;
    colormap(gray);
    for i=1:length(mov);
       imagesc(mov{i},clips(:)');
       title (sprintf('Frame %g of %g',i,length(mov)));
       drawnow;
    end
end
