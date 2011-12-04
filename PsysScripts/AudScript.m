A=Audacity;

A.addfile;

A.st2mon(A.tracks);

B=A.makecopy();

A.denoise();

% parmplot(A,B);