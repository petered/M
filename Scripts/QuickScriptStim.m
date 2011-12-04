close all hidden; clear classes; clc;

%% Setup
spikeFile='/projects/kevan/DataSylvia/GeneratedData/cat0710/spikeTimes_P2C1_ori.mat';
stimFile='/projects/kevan/DataSylvia/GeneratedData/cat0710/stimulusTimes_P2C1_ori.mat';


%%
S=SpikeBanhoff; S.Load_File(file);

%% Operations
S.sWidth=.03; % 30ms smoothing kernel.

x=S.sTS(:,2);
y=S.sTS(:,3);

x=x(1:floor(end/4)); y=y(1:floor(end/4));


%%

[c lag]=xcov(x,y,10000,'coeff');

subplot 211;
plot([x,y]);
subplot 212
plot(lag,c);

