%% Make practace files
clear; clc; close all;

M=MinistersCat.go;

M.whi.Shoe_RFs

[stim edges]=M.whi.C.StimGrab;
[spikes id]=M.whi.C.loadSpikeInfo;


disp 'ID''s:'
disp(id)

%% Select ID

chosenID=1;
spike=spikes(id==chosenID);

%% Divide into sets (training/test)

div=ceil(length(edges)/2);

s(1).stim=stim(:,:,1:div-1);
s(1).edges=edges(1:div);
s(1).spike=spike(spike<edges(div));

s(2).stim=stim(:,:,div:end);
s(2).edges=edges(div:end);
s(2).spike=spike(spike>edges(div));

%% Save

name=M.whi.name;
uisave({'s','name'},name);