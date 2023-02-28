function [data]=loadJSON(fullPath)

%% PURPOSE: LOAD A JSON FILE AND RETURN IT DECODED.

%% For retrieving the previously loaded data from the GUI appdata
    
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

%% Now that the data has been loaded, 
if exist('fig','var')==1 && Store_Settings 
    setappdata(fig,text,data);
end