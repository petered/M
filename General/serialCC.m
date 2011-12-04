function [SCC lagles]=serialCC(T,maxlag)
% Serial Correlation Coefficients
%
% T is a spike train
% Maxlag is the max lag

isis=diff(T);

v=var(isis);

mnsq=mean(isis)^2;


[co lagles]=xcorr(isis,maxlag);

SCC=(co/length(isis)-mnsq)/v;









end