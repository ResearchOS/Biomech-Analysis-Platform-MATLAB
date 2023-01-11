function []=writeJSON(path, json)

%% PURPOSE: WRITE A JSON TO FILE.

if ~isequal(path(end-4:end),'.json')
    path=[path '.json'];
end

if isstruct(json)
    json=jsonencode(json,'PrettyPrint',true);
end

fid=fopen(path,'w');
fprintf(fid,'%s',json);
fclose(fid);