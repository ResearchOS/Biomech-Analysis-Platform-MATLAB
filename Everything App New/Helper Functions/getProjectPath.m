function [projectPath]=getProjectPath(suppress)

%% PURPOSE: RETRIEVE THE PROJECT-SPECIFIC FOLDER PATH

rootSettingsFile=getRootSettingsFile();

load(rootSettingsFile,'Current_Project_Name');
fullPath=getClassFilePath(Current_Project_Name,'Project');
struct=loadJSON(fullPath);
computerID=getComputerID();

projectPath='';

if ~isfield(struct.ProjectPath,computerID)
    if nargin==0 % To not redundantly show this message when starting the app.
        disp('Select a path for the current project!');
    end
    return;
end

projectPath=struct.ProjectPath.(computerID);

if exist(projectPath,'dir')~=7
    if nargin==0
        disp('Select a path for the current project!');
    end
    projectPath='';
    return;
end