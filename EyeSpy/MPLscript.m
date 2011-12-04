close all hidden; clear classes; clc

imFile='C:\Documents and Settings\tobi\Desktop\MNIST\t10k-images.idx3-ubyte';
labFile='C:\Documents and Settings\tobi\Desktop\MNIST\t10k-labels.idx1-ubyte';

batch=100;
nSamp=4000;
% pad=10;
im=lowlevelreading(imFile,nSamp);
% im=padarray(im,[2 2]);
im=shakeitup(im,'trans',0.0);

lab=lowlevelreading(labFile,nSamp);
teach=lab2teach(lab);

ixtr=1:3000;
ixts=3001:4000;

% sim=shakeitup(padarray(im,[pad pad]),'scale',.2,'rot',.2,'trans',.4);
in=reshape(im,size(im,1)*size(im,2),[]);

% N=FFnetClass([size(in,1),10]);
N=FFnetClass([size(in,1),50,10]);

N.batchTrain(in(:,ixtr),teach(:,ixtr),16);

fprintf('Test Score: %g%%\n',100*N.testnet(in(:,ixts),teach(:,ixts)));

NetLister.FFnet2txt(N.L,[],[],true,5);