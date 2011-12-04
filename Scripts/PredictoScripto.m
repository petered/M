P=Predictosaurus;

P.loadfile;

P.R=P.R(:,2); % Only take the second (cell 1)

%%

lags=5;    % lags (in frames) to consider



P.STAtrain(10);

nhidden=5;
P.NNtrain(10,nhidden);

%%

 P.corrcompute;