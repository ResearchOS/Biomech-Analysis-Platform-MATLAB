function []=newComputerProjectPaths(computerID)

%% PURPOSE: ENSURE THAT THERE ARE FIELDS FOR THE COMPUTER-SPECIFIC PATHS

rootSettingsFile=getRootSettingsFile();
load(rootSettingsFile,'Current_Project_Name');

projectPath=getClassFilePath(Current_Project_Name,'Project');

projectStruct=loadJSON(projectPath);

if ~isfield(projectStruct.DataPath,computerID)
    projectStruct.DataPath.(computerID)='';
end

if ~isfield(projectStruct.ProjectPath,computerID)
    projectStruct.ProjectPath.(computerID)='';
end

writeJSON(projectPath,projectStruct);