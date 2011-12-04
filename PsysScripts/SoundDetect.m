% Start Detect
clear; clc;

% Get Files
A=Audacity;
[~,files]=A.addfile; % Select the audio tracks
al=A.tracks;

% Change to mono, cut the start
A.st2mon(al);
cutStart=0.5; % Cut this many seconds of the start
A.silence(al,0,cutStart);

noisesamp=A.grabrange(5,.6,2.5);

% Filter the noise
noiseStart=0.5;
noiseStop=1;
A.noiseFilt(al,noisesamp);
A.amplify(al,15);

% Find Start times
thresh=.02;
x=A.crossings(al,thresh,1);

[hL spacing]=A.mplot;
hold on
plot(x,spacing,'w*');
% 
% 
[outfile pth]=uiputfile('.xlsx');
outfile=[pth outfile];
outmat=[files' num2cell(OnsetTimes(:))];
xlswrite(outfile,outmat);