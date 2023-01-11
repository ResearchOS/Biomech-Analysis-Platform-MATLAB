function [filePath]=getProjectSettingsFile(src)

%% PURPOSE: GET THE CURRENT PROJECT'S SETTINGS FILE.

fig=ancestor(src,'figure','toplevel');

slash=filesep;

rootSettingsFile=getRootSettingsFile();

load(rootSettingsFile,'Current_Project_Name');

fullPath=getClassFilePath(Current_Project_Name, 'Project', fig);
struct=loadJSON(fullPath);

computerID=getComputerID();
projectPath=struct.ProjectPath.(computerID);

filePath=[projectPath slash 'Project_Settings' slash 'ProjectSettings.json'];