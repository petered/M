% This script is meant to show on what frequency inter-trial correlations
% arise.  It does this by taking the cross correlation of the raw signals
% for all trials, and convolving it with the autocorrelation of the filter
% for different filters.  This is equivalent to taking the coross
% correlation for the different filtered signals.

S=SpikeBanhoff.go;

widths=logspace(log10(0.01),log10(1),50);
for i=1:length(widths) S.sWidth=widths(i);
DR(:,:,i)=S.Drivenness;
end
M=mean(DRR(:,:,1),1);
[~,ix]=sort(M);



% Plot
plot(widths,DRR(:,ix(end-5:end),1),'w');
    xlabel 'smoothing kernel width (s)';
    ylabel('Drivenness')% (<C_{in}> - <C_{out}>)^2/(var(C_{in})> + var(C_{out}))');
title(sprintf('Correlation within trials vs. \nCorrelation between trials\n%s',S.name));
DRR=permute(DR,[3 1 2]); % width, stim, neuron