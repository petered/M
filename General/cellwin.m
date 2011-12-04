function [h hF]=cellwin(C,varargin)
% Window to show cell array data.

hF=figure(ceil(rand*10000));

if islogical(C) || isnumeric(C)
    C=num2cell(C);
end


x=strcmpi(varargin(1:2:end),'name');
if any(x)
    ix=find(x,1,'last')*2;
    set(hF,'name',varargin{ix});
    varargin(ix-1:ix)=[];
end



ix=cellfun(@(x)numel(x)>1,C(:));
C(ix)=cellfun(@(x)['[',num2str(x),']'],C(ix),'uniformoutput',false);

h=uitable('data',C,'units','normalized','position',[0 0 1 1],varargin{:});
% h=uitable('data',C);

end