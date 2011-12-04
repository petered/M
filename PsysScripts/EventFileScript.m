clear; close all
A=EventFileReader.go;

% These experiments have weird bunches of events at the beginning.
% Discard before a certain time to get rid of these.
discardBefore=21.8;   % Discard all events before X seconds from start
A.E=A.E([A.E.time]>discardBefore);
% A.repairtimes('Snd+');
times=[A.E.time];

disp Codes:
disp(unique({A.E.code}))

% Stimulus Parameters
audtrig=40;
vistrig=40;
ixSnd=A.isgroup('code', 'Snd+');
ixPostStim=[A.E.audi]==audtrig | ([A.E.visu]==vistrig);
ixStim=A.findlastix(ixSnd,ixPostStim);
tStim=times(ixStim);

% Response Parameters
ixResp=strcmp({A.E.code},'DIN1');
tResp=times(ixResp);

% Calculate times
timein=0;       % Time (s) after stim to start considering response
timeout=2;    % Time (s) after stim to stop considering response
[RT correct]=A.getRTs(tStim,tResp,[timein timeout]);

% Output to screen
disp '==== Results ===='
fprintf ('Correct (%g/%g)\n', nnz(correct),length(correct));
fprintf( 'Reaction Time (mean=%g)\n',mean(RT(~isnan(RT))));

% Plot
A.plottimes(ixStim,ixResp,ixSnd,A.isgroup('code', 'TRSP'));