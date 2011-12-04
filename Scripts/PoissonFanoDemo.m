% PoissonFanoDemo

S=SpikeBanhoff.go;

S.sWidth=0.1;

P=S.Poissonification;

S.Plot_Raster;
hF1=gca;

P.Plot_Raster;
hF2=gca;


figure(11);
h1=subplot(1,2,1);
h2=subplot(1,2,2);
ax2ax(hF1,h1);
ax2ax(hF2,h2);

subplot(h1); h=allchild(gca);  legend(h(strcmp(get(h,'type'),'hggroup')),strcat(S.NeuronLabels',': <FF>=',num2str(mean(S.FanoFactor,2)),',<nS>=',num2str(mean(S.nS,2))),'location','southoutside')
subplot(h2); h=allchild(gca);  legend(h(strcmp(get(h,'type'),'hggroup')),strcat(P.NeuronLabels',': <FF>=',num2str(mean(P.FanoFactor,2)),',<nS>=',num2str(mean(P.nS,2))),'location','southoutside')
