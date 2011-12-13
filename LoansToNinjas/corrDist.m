function [y2]=corrDist(x,y,c)
% Take sets of points drawn from two independent distributions and
% correlate them.  
%
% This function basically just modifies the y distribution to be some
% linear combination of the x and the original y distribution.

assert(length(x)==length(y),'x and y must be equal length');

% xp=x;

xm=mean(x); xs=std(x);
ym=mean(y); ys=std(y);

% 
x=(x-xm); x=x/xs;
y=(y-ym); y=y/ys;


% c=.7;
k=sqrt(1/c^2-1);

z=x+k*y;

z=(z-mean(z)); z=z/std(z);

z=z*ys+ym;

y2=z;
