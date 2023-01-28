function [filePath]=getProjectSettingsFile()

%% PURPOSE: GET THE CURRENT PROJECT'S SETTINGS FILE.

slash=filesep;

rootSettingsFile=getRootSettingsFile();

load(rootSettingsFile,'Current_Project_Name');

fullPath=getClassFilePath(Current_Project_Name, 'Project');
struct=loadJSON(fullPath);

computerID=getComputerID();
projectPath=struct.ProjectPath.(computerID);

filePath=[projectPath slash 'Project_Settings' slash 'ProjectSettings.json'];