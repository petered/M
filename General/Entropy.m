function [H sym]=Entropy(x)
    % Entropy of sample x, in bits.
    % in nlogn time, which is a bit wasteful, but I don't care.
    
    
    dim=find(size(x)>1);

    y=sort(x);
    
    newix=cat(dim,1,find(diff(y))+1);
    
    counts=diff(cat(dim,newix,length(y)+1));
      
    p=counts/length(x);
    
    H=-sum(p.*log2(p));
    
    sym=x(newix);

end