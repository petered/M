

% Movie Example
file= '/projects/kevan/StimulusPresentation/Movie/Clips/movie01.mat';

% White Noise Example
% file= ('/projects/kevan/DataSylvia/MastersThesis/RawData/cat1208/stimuli/cat1208_P10C2_whitenoise.mat');

% Grating Example
S=StimulusClass;
S.loadstim(file);

%%

S.Play_Base_Stim;