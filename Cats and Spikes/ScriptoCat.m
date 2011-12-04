function A=ScriptoCat
% =========================================================================
% ScriptoCat (<a href="matlab:A=ScriptoCat">Run</a>) (<a href="matlab:edit('ScriptoCat')">Edit</a>)
% 
% Welcome to ScriptoCat.  This script contains the functions and parameters
% that a user can edit to extract statistics from the cat data.  Click the 
% "Edit" button above to see this script, or the "Run" to start it.    
%
% You will first be prompted to select some cats from the list.  If there's
% a cat not already in the list, you can add one through the GUI.  If you
% then save, it'll be there next time you open.  Internally, this is all
% taken care of by the <a href="matlab:help('FelineFileFinder')">FelineFileFinder</a> object.
%
% After selecting a list of cats, you will be returned to the base
% workspace, with a nice GUI that allows you to view data extracted from
% the experiments, along with the statistics that you defined in this file.
% 
% In the base workspace, you will find the object A.  Through this, you can
% access all the data from all the cats.  For instance ">>A.C(4).S" will
% return an object containing all the Spike-Train data for cat 4.  The name
% of cat 4 can be found by ">>A.C(4).name".  "A.C(4).S.T{2,5}" returns the
% spike times for the 2nd neuron from the 5th trial for cat 4.
%
% Basic Map of Object (not all properties, no methods shown)
% A: <a href="matlab:edit('CatInTheStat')">CatInTheStat</a> object, used for extracting statistics from these experiments. 
%  Properties:
%   .stats: Structure array of statistics, with fields 'name','fun'.  See
%       ScriptoCat for how to build this array.
%   .groups: Structure array of groups, with fields 'name','fun'.  See
%       ScriptoCat for how to build this array.
%   .filter: Handle to function with boolean output and StimCat (see below)
%       input which decides whether to extract statistics from that cat.
%       Leave empty to extract stats from all cats.
%   .preproc: Handle to function that takes a StimCat (see below) input and
%       performs some kind of pre-processing.  Leave empty if you don't
%       want to do any preprocessing.
%   .D: Cell array containing results of calculations.  D{i,j} contains the
%       result of calculating statistic j on experiment i.
%   .C: <a href="matlab:edit('StimCat')">StimCat</a> object, representing a single experiment. 
%     Propeties:
%       .name: Name of the experiment
%       .type: Type (one of 'tuning','whitenoise','movies')
%       .D: Object containing data on the stimulus.
%       .FC: <a href="matlab:edit('FileCat')">FileCat</a> object, used for getting Raw Data.
%       .K: Structure defining Kernal as obtained from RevCorr Method (not
%           shown here - just works for whitenoise experiments)
%       .S: <a href="matlab:edit('SpikeBanhoff')">SpikeBanhoff</a> object. Contains the spiking data, 
%           and methods to view and interpret it.
%         Properties:
%           .T: Cell array containing spike times.  Indexed by {neuron, trial}
%           .isi: Equivalent cell array, containing ISI's.
%           .TS: Matrix containing binary-binned representation of spike
%               train .resolution property (not shown here) defines binning
%           .sTS: Smoothed version of TS.  See .sWidth and .sType for
%               smoothing kernel properties (not shown here).
%           .FC: <a href="matlab:help('FileCat')">FileCat</a> object, used for getting Raw Data. 
%
% To Skip this whole help screen in the future, just run A=ScriptoCat in
% the command line.
% 
% =========================================================================

% Just run A=ScriptoCat in the command line to run this directly.

if nargout==0
    help(mfilename);
    return;
end


evalin('base','close all hidden; clear classes; clc;');

A=CatInTheStat;
if ~A.loadCats, return; end
A.copyCats=false;       % copyCats=true mean you copy the object, and leave the original, before doing the preprocessing and statistics.  

A.filter=@filterFun;
A.preproc=@preProc;

%% Define Statistics of Interest

A.stats(1).name='MeanFanoFactor';
A.stats(1).fun=@(A)mean(A.S.FanoFactor,2);

A.stats(2).name='MeanSpikeCount';
A.stats(2).fun=@(A)mean(A.S.nS,2);

A.stats(3).name='MaxIntraTrialCorr';
A.stats(3).fun=@(C) max(C.S.intraTrialCorr);

A.stats(4).name='Subsequent ISI Mutual Information (6 divisions)';
A.stats(4).fun=@(C)C.S.ISI_MI(6,1);

%% Define Groups
A.groups(1).name='Movies';
A.groups(1).fun=@(C)strcmp(C.type,'movies');

A.groups(2).name='Tuning';
A.groups(2).fun=@(C)strcmp(C.type,'tuning');

%% Get 'er done

% A.crunch;
A.GUI;

end

function valid=filterFun(C)
    %% Test whether to run file.
    
    valid=true;
    
    if strcmp(C.type,'whitenoise')
        valid=false; 
        return;
    end


end


function preProc(C)
    %% PreProcessing Commands to run
    
    C.S.sWidth=0.2;     % Smoothing kernel width to 0.2s
    
    C.S.sType='gauss';  % Gaussinan smothing kernek (width is fwhh)
    
    C.S.cropTimes([0 2]);    % Trim the trials.
    
    C.S.takeMaxCell;    % Only take the most active cell.

end


