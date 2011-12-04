function im=MapCenterer(im)
% Note that this doesn't actually do the jop properly - it wraps edges
    

    xd=mean(im,1);
    yd=mean(im,2);
    
    xc=sum(xd./repmat(sum(xd,2),[1 size(xd,2)]).*repmat((1:size(im,2)),[1,1,size(im,3)]),2);
    yc=sum(yd./repmat(sum(yd,1),[size(yd,1) 1]).*repmat((1:size(im,1))',[1,1,size(im,3)]),1);

    cent=([size(im,1) size(im,2)]+1)/2;
    
    for i=1:size(im,3)
        
        off=round([yc(i) xc(i)]-cent);
        
        im(:,:,i)=circshift(im(:,:,i),-off);
        
    end

end