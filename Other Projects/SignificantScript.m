clear; clc; close all;

%% Parameters

nSubj=60;                   % Number of subjects
nTries=400;                 % Number of times to repeat experiment
nVox=40;                    % Number of Data Variables
effectiveVoxels=1:20;       % Subset of Data Variables that have the effect

% Parameters for Gaussian Data Distributions
baseMean=0;                 % Baseline/inactive voxel mean
baseStd=1;                  % Baseline/inactive voxel std
activeMean=.4;               % Active voxel mean
activeStd=1;                % Active voxel std

alpha=0.05;                 % Base-alpha value (see below for how it's adjusted)

% alpha-adjustment methods for significance testing methods
sigMethod='bonferroni';
M.bonferroni=@(alpha,nsamp) alpha/nsamp;
M.sidak=@(alpha,nsamp) 1-(1-alpha).^(1/nsamp);

% Effect measurement methods
effMethod='cohen';
E.cohen=@(M1,M2,dim)(mean(M1,dim)-mean(M2,dim))./sqrt(((size(M1,dim)-1)*var(M1,[],dim)+(size(M2,dim)-1)*var(M2,[],dim))/(size(M1,dim)+size(M2,dim)));
E.glass=@(M1,M2,dim)(mean(M1,dim)-mean(M2,dim)./std(M2,[],dim)); % Where M2 is the 'control' group
E.fischer=@(M1,M2,dim) (mean(M1,dim)-mean(M2,dim)).^2./(var(M1,[],dim)+var(M2,[],dim));

%% Generate The Data
DataBaseline=randn(nVox,nTries,nSubj)*baseStd+baseMean;
DataActive(setdiff(1:nVox,effectiveVoxels),:,:)=randn(nVox-length(effectiveVoxels),nTries,nSubj)*baseStd+baseMean;
DataActive(effectiveVoxels,:,:)=randn(length(effectiveVoxels),nTries,nSubj)*activeStd+activeMean;


%% Take the TTest

% Try a Two-Tailed-T-Test over subjects: tests if DataActive has a HIGHER
%   mean than DataBaseline
newalpha=M.(sigMethod)(alpha,nVox);
[passers,prob]=ttest(DataActive,DataBaseline,newalpha,'right',3);

%% Show the effect estimates

% Generate nVox x nTries matrix of effectiveness.
effects=E.(effMethod)(DataActive,DataBaseline,3);

% Define the 'active' and 'inactive' groups
groups={'active','inactive'};
grsets={effectiveVoxels,setdiff(1:nVox,effectiveVoxels)};

for i=1:2
    G=struct();
    G.data=effects(grsets{i},:);
    G.nvox=size(G.data,1);
    G.passers=passers(grsets{i},:);
    G.npass=sum(G.passers);
    G.maxpass=max(G.data.*G.passers); G.maxpass(G.npass==0)=nan;
    G.meanpass=sum(G.data.*G.passers)./G.npass;
    G.mean=mean(G.data);
    
    eff.(groups{i})=G;
    
end


%% Plot the results

subplot(4,1,1)

hist([reshape(DataBaseline(effectiveVoxels,:,:),[],1),reshape(DataActive(effectiveVoxels,:,:),[],1)],20)
legend('Baseline','Active');
title '"voxel" values over all active voxels, subjects and trials'

h=nan(1,2);
for i=1:2
    h(i)=subplot(4,1,1+i);
    G=eff.(groups{i});
    hist([G.maxpass' G.meanpass' G.mean'],30)
    legend('Max passing-Voxel Effect',sprintf('Mean-Passers Effect (%g%% pass rate) @%s=%.3e',100*mean(G.npass)/G.nvox,'\alpha',newalpha),'Real Effect');
    title (['Effect Measurements for ' groups{i} ' group (' num2str(G.nvox) ' "voxels")']);
end
tt=[xlim(h(1));xlim(h(2))]; tt=[min(tt(:,1)) max(tt(:,2))]; xlim(h(1),tt),xlim(h(2),tt)


subplot(4,1,4)
nums=0:max(max(eff.(groups{1}).npass),max(eff.(groups{2}).npass))+1;
counts=histc([eff.(groups{1}).npass' eff.(groups{2}).npass'],nums-.5);
bar(nums,counts)
legend(strcat(groups,' passers (out of ', cellfun(@(x)num2str(length(x)),grsets,'uniformoutput',false),')'));
title 'Number of test passers by group'