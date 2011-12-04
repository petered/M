function mutantLena=retinafy(Lena,b)
% Transforms an image from cartesian to polar, mapping from the center.

sz=size(Lena);

[x y]=meshgrid(1:size(Lena,1),1:size(Lena,2));
% X=[x(:) y(:)];

% X2=newpix(X,b);
[x2, y2]=newpix(x(:),y(:),b);

x2=reshape(x2,sz);
y2=reshape(y2,sz);

mutantLena=interp2(Lena,x2,y2);

end


function [xn yn]=newpix(x,y,b)

mxx=max(x,[],1);
mnx=min(x,[],1);

mxy=max(y,[],1);
mny=min(y,[],1);

xc=(mnx+mxx)/2;
yc=(mny+mxy)/2;


x=x-xc;
y=y-yc;

% ang=atan(y./x);
% edge=min((mxx-xc)./abs(cos(ang)),(mxy-yc)./abs(sin(ang)));

d=sum([x y].^2,2);

dp= exp((b/max(d))*d)-1;

% dp=dp.*max(d)./max(dp);
dp=dp.*max(d)./max(dp);

xn=x.*dp./d+xc;
yn=y.*dp./d+yc;

end