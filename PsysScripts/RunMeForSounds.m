A=Audacity;



%% Generate the Chord Sounds

chordChoice='Am';
switch chordChoice
    case 'Am', freq=[220 261.63 329.63];
    case 'C',  freq=[261.63 329.63 392];
end

chord=A.addchord(.17,freq,[1 .8 .6]); 

A.amp2max(chord,1); % Set max-amp to 1

noise=A.addnoisetrack([],.1);

% Do the fade in/out of chord
A.silence(chord,0,.065);
A.fadein(chord,.065,.075);
A.fadeout(chord,.16,.17,'quad');

% Do the noise fading
A.fadeout(noise,.065,.075);
A.silence(noise,.075,inf);

% Make the tha sound
thaC=A.merge([chord noise]);
A.fadein(thaC,0,.005);

% Make the ta sound
taC=A.merge([chord noise]);
A.silence(taC,0,.023);
A.fadein(taC,.023,.028);

% Make the da sound
daC=A.merge([chord noise]);
A.silence(daC,0,.048);
A.fadein(daC,.048,.053);

% Decide on some final amplitude
endamp=0.25;
A.amp2max(thaC,endamp);
A.amp2max(taC,endamp);
A.amp2max(daC,endamp);

%% Now load the Raw Sounds

% Load da/ta/tha and decide on their amplitudes
da=A.addfile('da.wav');
ta=A.addfile('ta.wav');
tha=A.addfile('tha.wav');

% Scale them to match each-other
finalamp=0.12;
meanda=A.meanamp(da,.08,.16);
meanta=A.meanamp(da,.08,.16);
meantha=A.meanamp(da,.08,.16);
A.amplify(da,finalamp);
A.amplify(ta,meanda/meanta*finalamp);
A.amplify(tha,meanda/meantha*finalamp);


%% Export the Results

% Export the chords
cd(fileparts(mfilename('fullpath')));
mkdir('./Generated Files');
cd './Generated Files';
A.export(thaC,['tha-length ' chordChoice]);
A.export(taC,['ta-length ' chordChoice]);
A.export(daC,['da-length ' chordChoice]);

% Export the scaled sounds
A.export(da,'da-Scaled');
A.export(ta,'ta-Scaled');
A.export(tha,'tha-Scaled');

