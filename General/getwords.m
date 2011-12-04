


function c=getwords(file)
fid=fopen(file);
c=textscan(fid,'%s');

c=cellfun(@(x)x(isletter(x)),c{1},'UniformOutput',false);

fclose(fid);
end