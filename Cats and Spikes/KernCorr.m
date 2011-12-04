function [C w]=KernCorr(TS1,TS2,widths,nfakes)

if ~exist('nfakes','var'), nfakes=0; end

TS1=bsxfun(@minus,TS1,mean(TS1));
TS2=bsxfun(@minus,TS2,mean(TS2));

% K=cell(1,length(widths));

[w]=nan(1,length(widths));
gauss=@(x,sd)exp(-x.^2/(2*sd^2));

xlen=2*size(TS1,1)-1;

[K Kf]=deal(cell(1,length(widths)));
buf=nan(1,length(widths));
for i=1:length(widths)
    spkern=gauss(-widths(i)*3:widths(i)*3,widths(i));
    w(i)=widths(i);
    kk=xcorr(spkern/sum(spkern))*sqrt(w(i)); 
    K{i}=kk-mean(kk);
    
    buf(i)=(2*size(TS1,1)-1-length(K{i}))/2;
    
%     if length(K{i})>2*size(TS1,1)-1
        Kf{i}=nan(nfakes,length(K{i}));
        for k=1:nfakes
            Kf{i}(k,:)=circshift(K{i},[1 floor(rand*length(K{i}))]);
        end
        Kf{i}=Kf{i}(:,1:min(length(K{i}),xlen));
%     end
end


C=nan(size(TS1,2),length(widths));
fprintf('Comptuing pair...');
for j=1:size(TS1,2)
    fprintf('%g..',j);
    [xc lags]=xcorr(TS1(:,j),TS2(:,j),'coef');
    
    
%     for k=1:nfakes % Still inefficient: could be improved
%         Xf(:,k)=circshift(xc,[floor(rand*length(xc)) 1]);
%     end
%     
    
    
    for i=1:length(widths)
        
        
        
        if buf(i)<0
            reals=K{i}(-buf(i)+1:end+buf(i))*xc;
%             if nfakes
%                 fakes=Kf{i}(:,-buf(i)+1:end+buf(i))*xc;
%             end
        else
            reals=K{i}*xc(buf(i)+1:end-buf(i));
%             if nfakes
%             fakes=K{i}*Xf(buf(i)+1:end-buf(i),:);
%             end
        end
        
        
        
        if nfakes
            kS=size(Kf{i},2);
            nframes=floor(length(xc)/kS);
            Xf=reshape(xc(1:nframes*kS),kS,[]);
            fakes=Kf{i}*Xf;
%             val=abs(fakes)>eps;
%             if isempty(val),C(j,i)=nan; continue; end
            C(j,i)=(reals-mean(fakes(:)))/std(fakes(:));
        else
            C(j,i)=reals;
        end
    end
    
    
    
end
disp Done

C=mean(C(all(~isnan(C),2),:),1);

% C=mean(C,1);

% 
% if nfakes
%     CF=nan(nfakes,length(widths));
%     for i=1:nfakes
%         fprintf('Control trial %g: ',i)
%         TS2p=nan(size(TS2));
%         for j=1:size(TS2,2)
%             TS2p(:,j)=TS2(randperm(size(TS2,1)),j);
%         end
%         CF(i,:)=KernCorr(TS1,TS2p,widths); 
%     end
%     C=(C-mean(CF))./std(CF);
% end
% 




end