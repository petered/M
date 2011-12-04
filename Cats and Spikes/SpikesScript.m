close all hidden; clear classes; clc;

%% Setup
% spikeFile='/projects/kevan/DataSylvia/GeneratedData/cat0710/spikeTimes_P2C1_ori.mat';
% stimFile='/projects/kevan/DataSylvia/GeneratedData/cat0710/stimulusTimes_P2C1_ori.mat';

file='/projects/kevan/DataSylvia/MastersThesis/RawData/cat1608/P5C1_movies/times_data.mat';



%%
S=SpikeBanhoff; S.Load_File(file);

%% Fake it

S=SpikeBanhoff; S.Poisson_Factory(1:3,5,1.582e3);

%% Operations


% x=x(1:floor(end/4)); y=y(1:floor(end/4));


%%
widthVec=[.001 .003 .01 .03 .1 .3];
% 
% S.T{5}=PoissonTrain(30,60);
% S.T{6}=PoissonTrain(30,60);

figure;
for i=1:length(widthVec)
    S.sWidth=widthVec(i); % 30ms smoothing kernel.
    x=S.sTS(:,5);
    y=S.sTS(:,6);
    
    [c lag]=xcov(x,y,10000,'coeff');
    plot(lag,c);
    hold all;
    drawnow;
end
