beta=0.5;
eta=1;

g=@(h)1/(1+exp(-2*h*beta));
gp=@(h)g(h).*(1-g(h));


w=[.2 -.1 0 .1 .2];
i1=[1 0];

inp=[1 1 0];

disp Outputs:

Sh=sum(inp.*w(1:3));
Oh=g(Sh)

So=sum([inp(1) Oh].*w([5 4]));
Oo=g(So)



do=(1-Oo)*gp(So);
dh=do*w(4)*gp(Sh);

disp 'Weight Changes'

d_w(5)=eta*do*1;
d_w(4)=eta*do*Oh;
d_w(3)=eta*dh*inp(3);
d_w(2)=eta*dh*inp(2);
d_w(1)=eta*dh*inp(1);

d_w

disp ==================

w=w+d_w

 inp=[1 1 1];