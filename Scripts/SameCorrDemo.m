% This script just demonstrates that taking the covariance of two 
% fir-filtered mean-subtracted signals is the same thing as taking the
% convolution of the covariance of the raw signals with the autocorrelation
% of the filter.  woo.

x=randn(1,1000);
y=randn(1,1000);
k=rand(1,20);


plot(conv(xcov(x,y),xcorr(k,k)));
hold all;
plot(xcov(conv(x-mean(x),k),conv(y-mean(y),k)))


legend('conv(corr(x,y),xcorr(k,k))','xcorr(conv(x,k),conv(y,k))')