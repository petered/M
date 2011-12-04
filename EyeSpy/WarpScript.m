close all hidden; clear classes; clc


A=WarpMe;


IM=lowlevelreading('C:\Documents and Settings\tobi\Desktop\MNIST\t10k-images.idx3-ubyte',50);

im=IM(:,:,12);

A.draw(im);

vert=A.vert;


%%

A.vert=vert+1*rand(size(A.vert));

A.rigidity=.00; 
A.attraction=.1;

A.fit(im,10000);