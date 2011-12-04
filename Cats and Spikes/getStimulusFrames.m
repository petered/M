function stimulusFrames = getStimulusFrames(stimuli)
% Returns a representation of each frame of the noise stimulus.

% stimuli           structure describing the noise stimulus; was saved
%                   during the experiment
%
% stimulusFrames    <rows x columns x frames double>; the first 2
%                   dimensions indicate the appearance of the single
%                   frames, the 3rd dimension specifies the number of the
%                   stimulus frame; entries are either 0 coding for a black
%                   rectangle, or 1 coding for a white rectangle, e.g.
%                   stimulusFrames(r,c,f) specifies the color of the
%                   rectangle in the r-th row of the c-th column of frame f

if isfield(stimuli, 'rectangleSize')  % for cat0209 (25.02.2009)
    totalFrames = length(stimuli.msequence) * stimuli.presentations + ...
        stimuli.memory;
    rows = stimuli.inputs(1);
    columns = stimuli.inputs(2);
    switch stimuli.memory
        case 14
            lag = 73;
        case 15
            lag = 145;
        case 16
            lag = 291;
        otherwise
            lag = round(length(stimuli.msequence) / (rows * columns));
    end
elseif isfield(stimuli, 'squareWidth')  % for cat1208 (09.10.2008) - cat1908 (11.12.2008)
    totalFrames = length(stimuli.msequence) + stimuli.memory;
    if mod(totalFrames, stimuli.cycleSize) <= stimuli.cycleSize / 2
        % in these cases the presentation of the noise stimulus was stopped
        % too early and not all planned frames were presented
        totalFrames = totalFrames - ...
            rem(totalFrames, stimuli.cycleSize / 2) - stimuli.cycleSize / 2;
    end
    rows = ceil(stimuli.Height / stimuli.squareWidth);
    columns = ceil(stimuli.Height / stimuli.squareWidth);
    lag = round(length(stimuli.msequence) / (rows * columns));
elseif isfield(stimuli, 'lags')  % since cat0210 (25.02.2010)
    totalFrames = length(stimuli.msequence) * stimuli.cycles + stimuli.memory;
    rows = stimuli.rows;
    columns = stimuli.columns;
    lag = stimuli.lags;
else
    display('The stimuli structure has an unknown format.');
    return
end

stimulusFrames = zeros(rows, columns, totalFrames);
sequIndices = mod(repmat((1:totalFrames)', 1, rows * columns) + ...
    repmat((0 : rows*columns-1) * lag, totalFrames, 1), ...
    length(stimuli.msequence));
sequIndices(sequIndices == 0) = length(stimuli.msequence);

for f = 1:totalFrames
    stimulusFrames(:,:,f) = reshape(...
        stimuli.msequence(sequIndices(f,:)), columns, rows)';
end