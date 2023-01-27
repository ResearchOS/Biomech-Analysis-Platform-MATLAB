function []=projectPathFieldValueChanged(src)

%% PURPOSE: SET THE PROJECT PATH

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

path=handles.Projects.projectPathField.Value;

if isempty(path)
    return;
end

projectNode=handles.Projects.allProjectsUITree.SelectedNodes;

fullPath=getClassFilePath(projectNode,'Project');
struct=loadJSON(fullPath);

if exist(path,'dir')~=7
    disp('Specified path is not a directory or does not exist!');
    return;
end

computerID=getComputerID();

struct.ProjectPath.(computerID)=path;

saveClass(fig,'Project',struct);

%% Create settings directory in specified project folder.
slash=filesep;
classNames=getappdata(fig,'classNames');

settingsPath=[path slash 'Project_Settings'];

warning('off','MATLAB:MKDIR:DirectoryExists');
mkdir(settingsPath);
for i=1:length(classNames)
    classPath=[settingsPath slash classNames{i}];
    mkdir(classPath);
end

projectSettingsFile=getProjectSettingsFile(fig);
initProjectSettingsFile(projectSettingsFile);

warning('on','MATLAB:MKDIR:DirectoryExists');

setappdata(fig,'existProjectPath',true);

projectSettingsFile=getProjectSettingsFile(fig);
initProjectSettingsFile(projectSettingsFile, fig);