function [data]=loadJSON(str)

%% PURPOSE: LOAD A JSON FILE AND RETURN IT DECODED.

%% For retrieving the previously loaded data from the GUI appdata

% SHOULD LOADJSON CHECK THAT ALL REQUIRED FIELDS EXIST?
% Only when creating new Projects does anything really have to be
% initialized (an analysis)

% Provided a UUID, not a file path.
if ~contains(str,filesep)
    fullPath = getJSONPath(str);
else
    fullPath = str;
end
    
rootSettingsFile=getRootSettingsFile;
load(rootSettingsFile,'Store_Settings');

if Store_Settings
    try
        fig=evalin('base','gui');
    catch
        fig=findall(0,'Name','pgui');
    end
    [~,fileName]=fileparts(fullPath);
    underscoreIdx=strfind(fileName,'_');
    if ~isempty(underscoreIdx)
        text=fileName(underscoreIdx(1)+1:end); % Remove the class prefix
    else
        text=fileName;
    end
    data=getappdata(fig,text);
    if ~isempty(data)
        return; % Returns empty if the variable is not found in
    end
end

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

% Check that this struct contains all required fields
[name, abstractID, instanceID]=deText(data.UUID);
instanceBool=true; % Initialize
if isempty(instanceID)
    instanceBool = false;    
end
compStruct = createNewObject(instanceBool, data.Class, '', abstractID, instanceID, false);
compFieldnames = fieldnames(compStruct);
dataFieldnames = fieldnames(data);
missingFieldsIdx = ~ismember(compFieldnames,dataFieldnames);
if any(missingFieldsIdx)
    % 1. Identify which fields are missing from the actual data struct.    
    missingFieldnames = compFieldnames(missingFieldsIdx);
    % 2. Put those fields from the comparison struct into the actual data struct. 
    
end

%% Now that the data has been loaded, 
if exist('fig','var')==1 && Store_Settings 
    setappdata(fig,text,data);
end