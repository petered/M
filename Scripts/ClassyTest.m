close all; clear

load '/users/oconnorp/Desktop/CodeFiles/classPractice.mat';
% s is a length-2 structure with fields stim,spike,edges
% uiload
% 
U=UIlibrary;

% Test-training set
tr=1;
ts=2;

%% Find linear Kernel
 
[R ste lags]=RevCorr(s(tr).stim,s(tr).edges,s(tr).spike,0.3,0.005);
R=R-repmat(mean(s(tr).stim,3),[1,1,size(R,3)]);
figure; imagesc(lags,[],R(:,:)); U.spookymap(); 


%% Make Predicted image, compare

% spikesig=histc(s(ts).spike,s(ts).edges);
K=shiftdim(R,2);
QuickScriptStim.m
% Predict the signal, 
stimP=sigpredict(s(ts).spike,s(ts).edges,K,lags)';  
stimP=reshape(stimP,size(stimP,1),1,size(stimP,2));
% stimP=sign(stimP)*.5+.5;
% rn=iqr(stimP(:)); md=median(stimP(:));
% stimP(stimP > md-rn/2 & stimP < md+rn/2)=0; 
% stimP=sign(stimP).*abs(stimP).^-0;

% Compute correlation to Actual
stimA=s(ts).stim;
realcorr=corr(stimP(:),stimA(:));

figure; 
hax(1)=subplot('211');
imagesc(squeeze(stimP)); title 'Predicted'
hax(2)=subplot('212');
imagesc(squeeze(stimA)); title 'Actual'
U.buttons({sprintf('~c=%g',realcorr)});

U.linkmaxes(hax);

%% Look at significance of this correlation

nfakes=50;
fakecorr=arrayfun(@(zz)corr(stimP(:),stimA(randperm(numel(stimA)))'),nan(1,nfakes));

figure;
hist(fakecorr);
addlines(realcorr,'linewidth',2);
xlabel 'Correlation Coefficient';
title 'Stimulus Prediction'

legend('bootstrapped-predictions','real-deal');




