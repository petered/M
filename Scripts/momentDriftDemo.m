C=FelineFileFinder.go;

s=C.loadSpikeInfo;
d=diff(s);
dd=d(d<0.15);


nMoments=3;
winLength=100;
jump=100;
% % subSamps=5;
% mom=justamoment(dd,nMoments,winLength,jump,subSamps);
mom=justamoment(dd,nMoments,winLength,jump);



figure;

set(gcf,'defaultaxescolororder',jet(size(mom,2)));
if size(mom,3)>1
    plot3(squeeze(mom(1,:,:))',squeeze(mom(2,:,:))',squeeze(mom(3,:,:))','*');
    
else
    plot3([mom(1,:); nan(1,size(mom,2))],[mom(2,:);  nan(1,size(mom,2))],[mom(3,:); nan(1,size(mom,2))],'*');
    
end
hold on
plot3(squeeze(mom(1,:,:)),squeeze(mom(2,:,:)),squeeze(mom(3,:,:)),'color',[.7 .7 .7]);
    

grid on
xlabel 'moment 1'
ylabel 'moment 2'
zlabel 'moment 3'
title (sprintf('%s\nISI Moment Drift from blue (early) to red (late) \nover %g minutes',C.catName,(s(end)-s(1))/60)); 
