%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%    this functinon calculates spike-triggered average     %%%%%%%
%%%%%%%%    last update december 2010                           %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function rawSTA = STA(stimuli, spikes, stimulusTimes, msecDelay, shift)
%%
% stimuli           structure describing the stimuli presented; was saved
%                   during the experiment
%
% spikes            <spikes x 2 double>; each row represents one spike, 1st
%                   column indicates the ID of the neuron, 2nd column 
%                   states the spike time in msec          
% stimulusTimes     start time of presentation in sec
%
% msecDelay         time delay of stimulus that triggered the spike (msec)
%
% (randpos)         optional; shift of stimuli frames (number of frames)
%                   used for significance testing (i.e., bootstrap)
%
% rawSTA            <delay x framesize> Spike-triggered average
%

if isfield(stimuli, 'rectangleSize')  % for cat0209 (25.02.2009)
    totalFrames = length(stimuli.msequence) * stimuli.presentations + ...
        stimuli.memory;
    frameDuration = stimuli.stimulusDuration;
    rows = stimuli.inputs(1);
    columns = stimuli.inputs(2);
    stimulusCycles = stimuli.presentations;
    newspikes = spikes(:,[2,1]); % swap columns of spikes matrix for unification
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
    frameDuration = stimuli.stimulusDuration;
    newspikes = spikes(:,[2,1]);
    stimulusCycles = stimuli.presentations;
elseif isfield(stimuli, 'lags')  % since cat0210 (25.02.2010)
    totalFrames = length(stimuli.msequence) * stimuli.cycles + stimuli.memory;
    rows = stimuli.rows;
    columns = stimuli.columns;
    lag = stimuli.lags;
    frameDuration = stimuli.frameDuration;
    stimulusTimes = stimulusTimes{1};
    stimulusCycles = stimuli.cycles;
else
    display('The stimuli structure has an unknown format.');
    return
end

delay = round(msecDelay/frameDuration); %neuron memory in terms of number of signal frames
framesize = rows * columns; %size of frame

lags = (0 : framesize - 1) * lag;

%cut spikes that do not correspond to stimulation time
ind = newspikes(:, 1) > (stimulusTimes * 1000 + msecDelay) & ...
    newspikes(:, 1) < totalFrames * frameDuration;
newspikes = newspikes(ind,:);
newspikes(:,1) = newspikes(:,1) - stimulusTimes * 1000;

%repeat m-sequence
msequence = repmat(stimuli.msequence, 1, (stimulusCycles + 3));

neurons = setdiff(unique(newspikes(:,2)), 0); %vector of neurons' ID

%delete not identified spikes
index = newspikes(:,2) == 0;
newspikes(index, :) = [];

%separate spikes by neurons 
neuronSpikes = cell(1, length(neurons)); %array of vector of spikes of neurons recorded
for n = 1:length(neurons)
    k = newspikes(:,2) == n;
    neuronSpikes{n} = newspikes(k, 1);
end
numbNeurons = length(neurons);

%calculate STA

% Initialize STA matrices with zeros. Each row represents x ms delay  frame   
rawSTA = zeros(delay, framesize, numbNeurons);
framenumb = 1:delay; % the number of the frame back in time from a spike

for l = 1:numbNeurons
    spNeuron =  neuronSpikes{l};
    nspikes = length(spNeuron);
    for k = 1:nspikes
        if nargin > 4
            framepositions = round(spNeuron(k) / frameDuration) ...
                + shift - (framenumb - 1); % position of the frame before the k-th spike 
        else
            framepositions = round(spNeuron(k) / frameDuration) ...
                - (framenumb - 1); % position of the frame before the k-th spike 
        end
        rawSTA(:,:,l) = rawSTA(:,:,l) + msequence(repmat(framepositions', 1, length(lags)) + ...
            repmat(lags, length(framepositions), 1));
    end
    rawSTA(:,:,l) = rawSTA(:,:,l) / nspikes;
end
  












