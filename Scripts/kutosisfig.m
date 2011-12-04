
M1=MinistersCat.go;
M2=MinistersCat.go;
 
%%

I1=M1.mov.S.isidist(0.15);
I2=M2.mov.S.isidist(0.15);
k1=kurtosis(randss(I1{1},[100,1000]));
k2=kurtosis(randss(I2{1},[100,1000]));


%% Start Figures

M1.mov.S.Plot_Raster
hm1=gca;
M2.mov.S.Plot_Raster
hm2=gca;


figure(11)
h11=subplot(2,4,[1 2]);
h21=subplot(2,4,[5 6]);
h12=subplot(2,4,3);
h22=subplot(2,4,7);
h13=subplot(2,4,4);
h23=subplot(2,4,8);

ax2ax(hm1,h11);
ax2ax(hm2,h21);


subplot(h11), ylabel('Condition, Trial');
subplot(h21), ylabel('Condition, Trial');

%% ISI plots

subplot(h12), hist(I1{1},100);
set(findobj(gca,'Type','patch'),'facecolor','w');
xlabel('ISI (below 150ms)');
ylabel('count');

subplot(h22), hist(I2{1},100);
set(findobj(gca,'Type','patch'),'facecolor','w');
xlabel('ISI (below 150ms)');
ylabel('count');


%% Kurtosis Plots
subplot(h13),hist(k1,50), 
set(findobj(gca,'Type','patch'),'facecolor','w');
xlabel('kurtosis');
ylabel('count (1000 subsaples of 100 ISI''s < 150ms)');

subplot(h23),hist(k2,50), 
set(findobj(gca,'Type','patch'),'facecolor','w');
xlabel('kurtosis');
ylabel('count (1000 subsaples of 100 ISI''s < 150ms)');

U=UIlibrary;
L1=U.linkmaxes([h12,h22]);
U.linkmaxes([h11,h21],'x');
U.linkmaxes([h13,h23],'x');