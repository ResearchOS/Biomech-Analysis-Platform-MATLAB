function [data]=loadJSON(fullPath,varName)

%% PURPOSE: LOAD A JSON FILE AND RETURN IT DECODED.

if exist(fullPath,'file')~=2
    data=struct;
    error('File not found!');
    return;
end

% Read the json file as unformatted char
fid=fopen(fullPath);
raw=fread(fid,inf);
fclose(fid);
str=char(raw');

% Convert json to struct
data=jsondecode(str);

if nargin==2
    if iscell(varName) && length(varName)==1
        varName=varName{1};
    end
    
    if ~iscell(varName)
        if isfield(data,varName)
            data=data.(varName);
        else
            data=[];
        end
        return;
    end    

    for i=1:length(varName)
        data2.(varName{i})=data.(varName{i});
    end

    data=data2;
end