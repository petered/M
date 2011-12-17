function Xp=corrLink(X,Y,c,skewed)
% Redraw values from a normal distribution to acheive a correlation.

if ~exist('skewed','var'), skewed=false; end

if skewed
    X=sqrt(X);
%     Yp=Y;
    Y=sqrt(Y);
end

mX=mean(X);
sX=std(X);

mY=mean(Y);
sY=std(Y);

xc=c*sX*sY;
Sig=[sX^2 xc;xc sY^2];

Z=mvnrnd([mX,mY],Sig,length(X));

% [Xs,~]=sort(X);
% [~,iz]=sort(Z(:,1));
% revIz(iz)=1:size(Z,1);
% Xp=Xs(revIz);

[~,iy]=sort(Y);
[~,iz]=sort(Z(:,2));
% revIz(iz)=1:size(Z,1);

revIy(iy)=1:length(Y);
Xt=Z(iz,1);

Xp=Xt(revIy);

if skewed
   Xp=Xp.^2;
end



end