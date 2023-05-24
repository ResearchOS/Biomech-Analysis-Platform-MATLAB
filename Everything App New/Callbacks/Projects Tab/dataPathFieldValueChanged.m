function []=dataPathFieldValueChanged(src)

%% PURPOSE: SET THE DATA PATH

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

path=handles.Projects.dataPathField.Value;

if isempty(path)
    return;
end

rootSettingsFile=getRootSettingsFile();
load(rootSettingsFile,'Current_Project_Name');
project=Current_Project_Name;

fullPath=getClassFilePath(project, 'Project');
projectStruct=loadJSON(fullPath);

if exist(path,'dir')~=7
    disp('Specified path is not a directory or does not exist!');
    return;
end

computerID=getComputerID();

projectStruct.DataPath.(computerID)=path;

saveClass('Project',projectStruct);