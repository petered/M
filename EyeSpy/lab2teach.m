function t=lab2teach(lab)
            
        [u ,garb, n]=unique(lab);

        t=false(length(u),length(lab));

        ix=sub2ind(size(t),n,1:length(lab));

        t(ix)=true;

    end
        