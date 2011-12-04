function NiceFigure
% This function allows for easy viewing of a bunch of figures in a folder.
% Select multiple files using control or shift.
%
% Peter O'Connor
% peter.ed.oconnor@gmail.com

persistent directory;
if ischar(directory)&&isdir(directory), cd(directory); end

[file directory]=uigetfile('*.fig','Use CTRL or Shift to select multiple files','MultiSelect','on');
if isequal(file,0); return; end

filelist=strcat(directory,file);

close all

[h hList]=addlist(file);

i=1;
hFold=nan;
while true
    
    hF=openfig(filelist{i},'new');
    close(hFold(ishandle(hFold)));
    drawnow;
    
    uiwait(hList);
    if ~ishandle(hList), close all; return; end
    
    i=get(h,'value');
    hFold=hF;
    
    
end


end


function [h hL]=addlist(list)

    hL=figure('units','normalized',...
        'position',[0 .1 .12 .8],...
        'MenuBar','none',...
        'name','Selector');

    h=uicontrol(...
        'Style','listbox',...
        'string',list,...
        'units','normalized',...
        'position',[0 .1 1 .9],...
        'callback','uiresume(gcbf)'...
        );
    
    uicontrol(...
        'Style','pushbutton',...
        'string','New Figure Set',...
        'units','normalized',...
        'position',[0 0 1 .1],...
        'callback',['close all; ' mfilename]...
        );



end