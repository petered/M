function [paths files]=Crawler(rootpath)
% Search for MAT files in a given folder

% rootpath='\\132.216.58.109\Drobo (E)\ElectroPhys\Analyzed Data';

paths=getpaths(rootpath);
if nargout>1, files=getfiles(paths); end



end


function paths=getpaths(rootpath)

    pathlist=genpath(rootpath);

    if ispc
        t=textscan(pathlist,'%s','delimiter',';');
    else
        t=textscan(pathlist,'%s','delimiter',':');
    end
    paths=t{1};
        
%     semis=[0 find(pathlist==';')];
% 
%     paths=cell(length(semis)-1,1);
%     for i=1:length(semis)-1
%         paths{i}=pathlist(semis(i)+1:semis(i+1)-1);
%     end

end


function files=getfiles(paths)

    files={};
    for i=1:length(paths)

        st=what(paths{i});
        if isempty(st.mat), continue; end
        
        files=[files;  strcat(paths{i}, filesep, st.mat)];


    end

end
