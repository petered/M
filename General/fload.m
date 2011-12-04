function fload (varargin)
% Loads a file 

file=strcat(varargin{:});
file=regexprep(file,'%20',' ');


evalin('base',['F=load(''' file(8:end) ''');']);







end