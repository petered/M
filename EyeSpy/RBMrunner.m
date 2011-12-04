close all hidden; clear classes; clc;

%% Obtain image set.

S=ShowMeTheNumbhas;
if ispc
    S.imageFile='C:\Documents and Settings\Peter\Desktop\MNIST\t10k-images.idx3-ubyte';
    S.labelFile='C:\Documents and Settings\Peter\Desktop\MNIST\t10k-labels.idx1-ubyte';
else
    S.imageFile='/users/oconnorp/Desktop/MNIST/t10k-images-idx3-ubyte';
    S.labelFile='/users/oconnorp/Desktop/MNIST/t10k-labels-idx1-ubyte';
end

S.N=1000;
S.buffer=2;
S.rTrans=.05;
S.rScale=0.05;
S.rRot=0.05;
S.get;


%%

R=RBM;
in=R.setup(sim,200);

R.winit=.001;
R.eta=2;

R.ustrain(in,12);

% 
% R.showRFs;
% 
% 
% R.addlayer(10,0);
% lab=lowlevelreading(labFile,nSamp);
% teach=R.lab2teach(lab);
% R.eta=.02;
% R.strain(in,teach,20);