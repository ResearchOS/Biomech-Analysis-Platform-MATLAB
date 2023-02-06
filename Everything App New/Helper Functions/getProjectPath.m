function [projectPath]=getProjectPath(suppress,Current_Project_Name)

%% PURPOSE: RETRIEVE THE PROJECT-SPECIFIC FOLDER PATH

rootSettingsFile=getRootSettingsFile();

if exist('Current_Project_Name','var')~=1
    load(rootSettingsFile,'Current_Project_Name');
end
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