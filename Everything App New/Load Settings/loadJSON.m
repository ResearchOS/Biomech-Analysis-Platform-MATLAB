function [data]=loadJSON(fullPath)

%% PURPOSE: LOAD A JSON FILE AND RETURN IT DECODED.

if exist(fullPath,'file')~=2
    data=struct;
    return;
end

% Read the json file as unformatted char
fid=fopen(fullPath);
raw=fread(fid,inf);
fclose(fid);
str=char(raw');

% Convert json to struct
data=jsondecode(str);