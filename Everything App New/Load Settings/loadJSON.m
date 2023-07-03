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
    [~,uuid]=fileparts(fullPath);
%     underscoreIdx=strfind(fileName,'_');
%     if ~isempty(underscoreIdx)
%         text=fileName(underscoreIdx(1)+1:end); % Remove the class prefix
%     else
%         text=fileName;
%     end
    data=getappdata(fig,uuid);
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

if isfield(data,'Links') && length(fieldnames(data))<=2
    data = formatLinkageMatrix(data, 'read');
end

% Check that this struct contains all required fields. If it does not,
% default values are inserted. EXCEPT for UUID field, which throws an
% error.
data = checkFields(data);

%% Now that the data has been loaded, 
if exist('fig','var')==1 && Store_Settings 
    setappdata(fig,uuid,data);
end