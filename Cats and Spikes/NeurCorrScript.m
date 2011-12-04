function NeurCorrScript
    A=CatParliament;
    if ~A.loadCats, return; end
    A.copyCats=false;       % copyCats=true mean you copy the object, and leave the original, before doing the preprocessing and statistics.  

    A.filter=@filterFun;
    A.preproc=@preProc;

    %% Define Statistics of Interest

    A.stats(1).name='MeanFano 0.5';
    % A.stats(1).fun=@(SC)mean(SC.S.FanoFactor);
    A.stats(1).fun=@(SC)mean(cell2mat(RovingFanos(SC.S.T,0.5,SC.S.cond)));
    A.stats(1).groups=[1 2];



    %% Define Groups
    % The group fun takes in a MinisterCat object and outputs a StimCat object.

    A.groups(1).name='tuning';
    A.groups(1).fun=@(MC)MC.tun; 

    A.groups(2).name='movies';
    A.groups(2).fun=@(MC)MC.mov; 

    A.groups(3).name='whitenoise';
    A.groups(3).fun=@(MC)MC.whi; 

    A.splitCells; % Divide the cells

    A.minSpikesFilter(1); % Filter out experiments with <1 spike per trial.

    %% Get 'er done

    % A.crunch;
    % A.GUI;
