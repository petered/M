% Calate a prediction of the signal given a kernel function


close all; clear

load '/users/oconnorp/Desktop/CodeFiles/classPractice.mat';
% s is a length-2 structure with fields stim,spike,edges
% uiload

U=UIlibrary;

% Test-training set
tr=1;
ts=2;

%% Find linear Kernel
 
[R ste lags]=RevCorr(s(tr).stim,s(tr).edges,s(tr).spike,0.3,median(diff(s(1).edges)));
R=R-repmat(mean(s(tr).stim,3),[1,1,size(R,3)]);
figure; imagesc(lags,[],R(:,:)); U.spookymap(); 


%% Make Predicted image, compare

% spikesig=histc(s(ts).spike,s(ts).edges);

stimsig=shiftdim(s(ts).stim,2);
K=shiftdim(R,2);

%% Do math

csig=sum(convn(stimsig,K,'same'),2);

realcorr=eventCorr(csig,s(ts).edges,s(ts).spike);

nfakes=50;
fakecorr=arrayfun(@(zz)eventCorr(...
    sum(convn(stimsig(randperm(length(stimsig)),:),K,'same'),2),...
    s(ts).edges,s(ts).spike...
    ),nan(1,nfakes));




figure;
hist(fakecorr);
addlines(realcorr,'linewidth',2);
xlabel 'Correlation Coefficient';
title 'Stimulus Prediction'

legend('bootstrapped-predictions','real-deal');


