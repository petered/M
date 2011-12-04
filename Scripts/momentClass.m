% First create a file using StimclassProb.m
% 
% it should contain a structure s, with field psth.
% rows of s contain psth's for different stimuli,
% columns are psth's of different divisions of the data.  You can, for
% inscance, use one column for a training set and another for test.
% wipe
% uiload;
% load '/users/oconnorp/Desktop/CodeFiles/1208 Stimulus Class Exp.mat'


% s=StimclassProb('normal');

s=StimclassProb('fake');

%% Initialize into moment List

nSS=100;        % Take 100 subsamples of ISI distribution
nDR=500;        % Take 100 draws per subsampling
nmom=4;         % Take 6 moments
maxISI=0.1;    % Trash isi's bigger than 150ms

for i=1:numel(s)
    % Basically, for each set, take a random sub-sampling of the ISI's and
    % make a distribution out of it.
    
    % Grab ISI's
    s(i).isi=cell2mat(cellfun(@(y)diff(y),s(i).psth,'uniformoutput',false)');
    s(i).isi=s(i).isi(s(i).isi<maxISI);
    
    % Random subsample of isis
    s(i).rss=randss(s(i).isi,[nDR,nSS]);
    
    % Moment-matrix of random subsamples
%     s(i).mom=nan(nmom,nSS);
%     s(i).mom(1,:)=mean(s(i).rss);
%     for j=2:nmom
%         s(i).mom(j,:)=moment(s(i).rss,j);
%     end

    % Standardized Moments
    % 1: 2nd^(1/2)/mean
    % 2: 3rd/2nd^(3/2)
    % 3: 4th/2nd^(2)
    % ....
     s(i).mom=nan(nmom,nSS);
     st=std(s(i).rss);
     s(i).mom(1,:)=mean(s(i).rss)./st;
     for j=2:nmom
        s(i).mom(j,:)=moment(s(i).rss,j+1)./st.^(j+1);         
     end
     
    
end

%% Turn into Classification Problem

sts=[1 2]; % Test/training set

%t=struct('Dtrain',{},'Dtest',{},'Atrain',{},'Atest',{});

%     Step... ORDER BY CONDITION!
%     So that test and training data are not driven by same stimulus.
%     [~,ixc]=sort(cond);
%     psth=psth(:,ixc);
%     cond=cond(ixc);

t(sts(1)).D=[s(:,sts(1)).mom];
t(sts(1)).A=[zeros(1,nSS) ones(1,nSS)];

t(sts(2)).D=[s(:,sts(2)).mom];
t(sts(2)).A=[zeros(1,nSS) ones(1,nSS)];


%%  Plot it


d=[1 2 3];
figure;


for i=1:2
   if i==1, sym='o';
   else sym='+';
   end
   
   u=unique(t(sts(1)).A);
   for j=1:length(u)
       if j==1, col='y';
       else col='c';
       end
       scatter3(...
           t(sts(i)).D(d(1),t(sts(i)).A==u(j)),...
           t(sts(i)).D(d(2),t(sts(i)).A==u(j)),...
           t(sts(i)).D(d(3),t(sts(i)).A==u(j)),...
           [col sym]);
       hold on
   end
end

xlabel(sprintf('moment %g',d(1)));
ylabel(sprintf('moment %g',d(2)));
zlabel(sprintf('moment %g',d(3)));
legend([s(1,1).name '-training'], [s(2,1).name '-training'],[s(1,1).name '-test'], [s(2,1).name '-test']);
%%

guess=classify(t(sts(2)).D',t(sts(1)).D',t(sts(1)).A);
correct=nnz(guess==t(sts(2)).A');
score=correct/length(guess)*100;

title(sprintf('Projections of subsamples onto their moments\nClassification Score: %g/%g (%g%%)',correct,length(guess),score));


fprintf('Classification score: %g/%g (%g%%)\n',correct,length(guess),score);
if score<50
    disp 'You''re actually good at being wrong!'
elseif score<70
    disp 'Pretty Bad'
elseif score<90
    disp 'Not bad eh?'
else
    disp 'Rockin!'
end
