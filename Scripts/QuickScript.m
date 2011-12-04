
if true
close all hidden; clear classes; clc;
colordef black; % groovy
%% Setup
% file='/projects/kevan/DataSylvia/GeneratedData/cat0710/spikeTimes_P2C1_ori.mat';
% file='/projects/kevan/DataSylvia/MastersThesis/RawData/cat1608/P5C1_movies/times_data.mat';


clear M
len=MinistersCat.ListLength;
for i=1:len
    M(i)=MinistersCat;
    M(i).GrabCat(i);    
end
end

%% Get A list of the FanoFactors of the most powerfully spiking cells

conds={'movies' 'tuning'};

[FF N]=deal(nan(length(conds),length(M)));
goodix=false(1,length(M));
for i=1:length(M)
    if length(M(i).E)~=2, continue; end
    
    
    try 
        for j=1:length(conds)
            thisone=find(strcmpi({M(i).E.type},conds{j}));

            powcell=M(i).SpikerRank(true);
% 
%             ff=mean(M(i).E(thisone).S.FanoFactor,2);
            goodix(i)=true;
            [ff N(j,i)]=M(i).E(thisone).S.FatFanoFactor;
            
            FF(j,i)=ff(powcell);
        end
    
    catch ME
        fprintf('Error while analyzing %s:\n-----\n',M(i).name);
        disp(ME.getReport);
        disp -----------
        
    end
end

%%
figure;
barh(FF(:,goodix)'); hold on;
plot(N(1,goodix),1:nnz(goodix),'b-*');
plot(N(2,goodix),1:nnz(goodix),'r-*');
set(gca,'YTick',1:nnz(goodix))
set(gca,'YTickLabel',{M(goodix).name});
xlabel('FanoFacor');
legend([strcat(conds,'-FF'),strcat(conds,'-trialcount')]);
title('Fano-Factor of most frequently Spiking Neuron');