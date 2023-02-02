function [data]=loadJSON(fullPath)

%% PURPOSE: LOAD A JSON FILE AND RETURN IT DECODED.

%% For retrieving the previously loaded data from the GUI appdata
    
if exist('fig','var')~=1
    try
        fig=evalin('base','gui');
    catch
        fig=findall(0,'Name','pgui');
    end
end

rootSettingsFile=getRootSettingsFile;
load(rootSettingsFile,'Store_Settings');
if Store_Settings
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

if nargin>=2 && ~isempty(varName)    
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

%% Now that the data has been loaded, 
if exist('fig','var')==1 && Store_Settings 
    setappdata(fig,text,data);
end