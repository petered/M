clear; clc
DS=load ('fisheriris');


tr=1;
ts=2;
div=ceil(size(DS.meas,1)/2);



[uni,~,tar]=unique(DS.species);

% scramble it up
scramix=randperm(length(tar));
meas=DS.meas;
meas=meas(scramix,:);
tar=tar(scramix);


booltar=false(length(tar),length(uni));
booltar(sub2ind(size(booltar),(1:length(tar))',tar))=true;





%% setup inputs

s=struct;
s(tr).x=meas(1:div-1,:)';
s(tr).y=booltar(1:div-1,:)';

s(ts).x=meas(div:end,:)';
s(ts).y=booltar(div:end,:)';

net=feedforwardnet(5);


%% Train the 

net=train(net,s(tr).x,s(tr).y);

res=sim(net,s(ts).x);

bool2num=@(x)arrayfun(@(ii)find(x(:,ii)==max(x(:,ii))),1:size(x,2));

fprintf('Guessed: %s\n',num2str(bool2num(res)));
fprintf('Correct: %s\n',num2str(bool2num(s(ts).y)));
fprintf('Error Rate: %g%%\n',100*nnz(bool2num(res)~=bool2num(s(ts).y))/size(res,2));


