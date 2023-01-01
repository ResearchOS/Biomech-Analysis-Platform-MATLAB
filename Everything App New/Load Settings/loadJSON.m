function [data]=loadJSON(fullPath)

%% PURPOSE: LOAD A JSON FILE AND RETURN IT DECODED.

% Read the json file as unformatted char
fid=fopen(fullPath);
raw=fread(fid,inf);
fclose(fid);
str=char(raw');

% Convert json to struct
data=jsondecode(str);