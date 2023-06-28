function []=newComputerProjectPaths(computerID)

%% PURPOSE: ENSURE THAT THERE ARE FIELDS FOR THE COMPUTER-SPECIFIC PATHS

rootSettingsFile=getRootSettingsFile();
load(rootSettingsFile,'Current_Project_Name');

projectPath=getClassFilePath(Current_Project_Name,'Project');

projectStruct=loadJSON(projectPath);

doWrite = false;

if ~isfield(projectStruct.DataPath,computerID)
    projectStruct.DataPath.(computerID)='';
    doWrite = true;
end

if ~isfield(projectStruct.ProjectPath,computerID)
    projectStruct.ProjectPath.(computerID)='';
    doWrite = true;
end

if doWrite % Because a modification has been made.
    writeJSON(projectPath,projectStruct);
end