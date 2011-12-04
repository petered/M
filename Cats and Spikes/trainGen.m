function [T1 T2]=trainGen(rate,comm,dt,jitter)

if nargin<3, dt=1; end
if nargin<4, jitter=0; end

T1=PechePourPoisson(rate*(1-comm),dt);
T2=PechePourPoisson(rate*(1-comm),dt);
Tc=PechePourPoisson(rate*comm,dt);

T1=sort([T1;Tc+jitter*randn(size(Tc))]);
T2=sort([T2;Tc+jitter*randn(size(Tc))]);


