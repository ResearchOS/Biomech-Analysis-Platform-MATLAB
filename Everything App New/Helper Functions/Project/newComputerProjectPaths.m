function [projectStruct]=newComputerProjectPaths(pjUUID)

%% PURPOSE: ENSURE THAT THERE ARE FIELDS FOR THE COMPUTER-SPECIFIC PATHS

computerID = getComputerID();

projectStruct = loadJSON(pjUUID);
pjStructTmp = createNewObject(true,'Project','Default','','',false);

doWrite = false;
if ~isfield(projectStruct.ProjectPath,computerID)
    doWrite = true;
    projectStruct.ProjectPath.(computerID) = pjStructTmp.ProjectPath.(computerID);
end

if ~isfield(projectStruct.DataPath,computerID)
    doWrite = true;
    projectStruct.DataPath.(computerID) = pjStructTmp.DataPath.(computerID);
end

if doWrite
    writeJSON(getJSONPath(projectStruct), projectStruct);
end