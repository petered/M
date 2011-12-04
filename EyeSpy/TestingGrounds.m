close all hidden; clear classes; clc

%% Get the numbers

S=ShowMeTheNumbhas;
S.imageFile='C:\Documents and Settings\tobi\Desktop\MNIST\t10k-images.idx3-ubyte';
S.labelFile='C:\Documents and Settings\tobi\Desktop\MNIST\t10k-labels.idx1-ubyte';

S.N=1000;
S.buffer=2;
S.rTrans=.05;
S.rScale=0.05;
S.rRot=0.05;

S.get;


%% Train the Net

A=cRBM;
A.