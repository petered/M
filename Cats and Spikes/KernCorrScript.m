clear

rate=500;

jitter=.00002;

res=1/100000;

[T1 T2]=trainGen(rate,.5,1,jitter);


rng=[min(min(T1),min(T2)),max(max(T1),max(T2))];
    

TS1=binme(T1,res,rng);
TS2=binme(T2,res,rng);

% mscohere(TS1,TS2)
% axis([0 0.001 0 1])


% [x,lags]=xcov(TS1,TS2);
% clf; plot(lags*res,x); set(gca,'xlim',[-.0004 .0004]);
% hold all;
% for w=1:50
%     K=xcorr(ones(1,w)/w,ones(1,w)/w);
%     K=K-mean(K);
%     c=conv(x,K,'same')*sqrt(w);
%     cc(w)=c(ceil(end/2));
%     plot(lags*res,c);    
% end
% clf; plot((1:50)*res,cc);

% [m ix]=max(x);
% fprintf('lag at max: %g\n',lags(ix));

widths=linspace(1,1000,100);

[c widths]=KernCorr(TS1,TS2,widths,20);

% figure;
subplot 311
plot(widths*res,c);


h1=subplot(3,1,2);
cla
addlines(T1);


h2=subplot(3,1,3);
cla
addlines(T2);


linkaxes([h1 h2]);

[m ix]=max(c);

fprintf('Jitter:\n  Est: %g,\n  Act: %g\n',(widths(ix)-1)*res,jitter);

