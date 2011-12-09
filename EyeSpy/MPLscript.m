% close all hidden; clear classes; clc
% 
% if ispc
%     imFile='C:\Documents and Settings\tobi\Desktop\MNIST\t10k-images.idx3-ubyte';
%     labFile='C:\Documents and Settings\tobi\Desktop\MNIST\t10k-labels.idx1-ubyte';
% else
%     imFile='/users/oconnorp/Desktop/MNIST/t10k-images-idx3-ubyte';
%     labFile='/users/oconnorp/Desktop/MNIST/t10k-labels-idx1-ubyte';
% end
%     
%     
% batch=100;
% nSamp=40000;
% 
% 
% 
% % pad=10;
% im=lowlevelreading(imFile,nSamp);
% % im=padarray(im,[2 2]);
% % im=shakeitup(im,'trans',0.0);
% 
% 
% fractrain=3/4;
% ixtr=1:fix(fractrain*nSamp);
% ixts=fix(fractrain*nSamp)+1:nSamp;
% 
% 
% lab=lowlevelreading(labFile,nSamp);
% teach=lab2teach(lab);
% 
% 
% % sim=shakeitup(padarray(im,[pad pad]),'scale',.2,'rot',.2,'trans',.4);
% in=reshape(im,size(im,1)*size(im,2),[]);


S=ShowMeTheNumbhas;
S.imageFile='/users/oconnorp/Desktop/MNIST/train-images-idx3-ubyte';
S.labelFile='/users/oconnorp/Desktop/MNIST/train-labels-idx1-ubyte';
S.N=60000;

S.get();

S.buffer=0;
S.rTrans=.1;
S.rScale=0.1;
S.rRot=0.05;
S.applyTransforms();

S.trainfrac=.8;
S.labEncoding='1off';

%% Train Network 
%N=FFnetClass([size(in,1),10]);
N=FFnetClass([size(S.IMflat,1),50,size(S.teacher,1)]);

N.rate=0.01;
N.decay=0.00001;
N.batch=100;
epochCount=16;  % Number of epoches to train for
stopCrit=.98;   % Stop criterion (fraction of training set guessed).


N.batchTrain(S.trainIM,S.trainTeach,epochCount,stopCrit);

fprintf('Test Score: %g%%\n',100*N.testnet(S.testIM,S.testTeach));

% res=questdlg('Print Network?');
% switch res
%     case 'Yes'
%         NetLister.FFnet2txt(N.L,[],[],true,5);
% end
