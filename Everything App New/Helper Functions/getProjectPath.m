function [projectPath]=getProjectPath(src,suppress)

%% PURPOSE: RETRIEVE THE PROJECT-SPECIFIC FOLDER PATH

fig=ancestor(src,'figure','toplevel');

rootSettingsFile=getRootSettingsFile();

load(rootSettingsFile,'Current_Project_Name');
fullPath=getClassFilePath(Current_Project_Name,'Project',fig);
struct=loadJSON(fullPath);
computerID=getComputerID();

projectPath='';

if ~isfield(struct.ProjectPath,computerID)
    if nargin==1 % To not redundantly show this message when starting the app.
        disp('Select a path for the current project!');
    end
    return;
end

projectPath=struct.ProjectPath.(computerID);

if exist(projectPath,'dir')~=7
    if nargin==1
        disp('Select a path for the current project!');
    end
    projectPath='';
    return;
end