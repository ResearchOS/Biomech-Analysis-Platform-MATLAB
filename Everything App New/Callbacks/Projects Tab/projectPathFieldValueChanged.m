function []=projectPathFieldValueChanged(src)

%% PURPOSE: SET THE PROJECT PATH

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

path=handles.Projects.projectPathField.Value;

if isempty(path)
    return;
end

rootSettingsFile=getRootSettingsFile();
load(rootSettingsFile,'Current_Project_Name');
project=Current_Project_Name;

fullPath=getClassFilePath(project,'Project');
struct=loadJSON(fullPath);

if exist(path,'dir')~=7
    disp('Specified path is not a directory or does not exist!');
    return;
end

computerID=getComputerID();

struct.ProjectPath.(computerID)=path;

saveClass('Project',struct);

%% Create settings directory in specified project folder.
slash=filesep;
settingsPath=[path slash 'Project_Settings'];
initializeClassFolders(settingsPath);

projectSettingsFile=getProjectSettingsFile();
initProjectSettingsFile(projectSettingsFile);