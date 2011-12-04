function y=stretchy(x,b)

xmx=max(x);
xmn=min(x);

xm=mean([xmx,xmn]);

x=x-xm;
y=sign(x).*(exp(b*x.^2)-1);

y=y*x(end)/y(end);

y=y+xm;


end