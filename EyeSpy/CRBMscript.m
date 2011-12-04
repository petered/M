close all hidden; clear classes; clc;

%% Obtain image set.

S=ShowMeTheNumbhas;
S.imageFile='/users/oconnorp/Desktop/MNIST/t10k-images-idx3-ubyte';
S.labelFile='/users/oconnorp/Desktop/MNIST/t10k-labels-idx1-ubyte';
S.N=1000;
S.buffer=2;
S.rTrans=.05;
S.rScale=0.05;
S.rRot=0.05;
S.get;


%% Initialize Network

A=cRBM;

A.winit=.001;
A.eta=2;

A.init(size(S.IM,1),[],7,'conv');


%% 


