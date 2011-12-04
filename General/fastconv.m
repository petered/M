function m3=fastconv(a,b)
    % Does a conv in NlogN time, which is awesome.
    % should be the same, withing numerical error, as conv(a,b,'same');
    %
    % (c) 2010 peter
    
    de=false; re=false;
    if isvector(a)&&size(a,2)>1, a=a(:); de=true; end
    if isvector(b)&&size(b,2)>1, b=b(:); end
    
    
    
    sa=size(a);
    
    if length(sa)>2
       re=true;
       a=a(:,:); 
    end
    
%     pad=ceil(length(b)/2);
%     m=[ a ;zeros(pad, prod(sa(2:end)))];
%     m2=fftfilt(b,m);
%     m3=m2(pad+1:end,:);
    b2=padarray(b,(size(a,1)-size(b,1)),0,'post');
    b2=circshift(b2,-floor(length(b)/2));
    
    if size(a,2)>size(b,2)
       B=repmat(fft(b2),[1 size(a,2)]);
    else
       B=fft(b2);
    end
    
    m3=ifft(fft(a).*B);


    if de
        m3=m3';
    end
    
    if re
       m3=reshape(m3,[size(m3,1) sa(2:end)]); 
    end
    
end


