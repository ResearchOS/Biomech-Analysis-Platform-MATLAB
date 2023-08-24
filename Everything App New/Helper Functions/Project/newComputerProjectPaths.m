function [projectStruct]=newComputerProjectPaths(pjUUID)

%% PURPOSE: ENSURE THAT THERE ARE FIELDS FOR THE COMPUTER-SPECIFIC PATHS

computerID = getComputerID();

projectStruct = loadJSON(pjUUID);
pjStructTmp = createNewObject(true,'Project','Default','','',false);

doWrite = false;
if ~isfield(projectStruct,'ProjectPath') || ~isfield(projectStruct.ProjectPath,computerID)
    doWrite = true;
    projectStruct.ProjectPath.(computerID) = pjStructTmp.ProjectPath.(computerID); % Assign default
end

if ~isfield(projectStruct,'DataPath') || ~isfield(projectStruct.DataPath,computerID)
    doWrite = true;
    projectStruct.DataPath.(computerID) = pjStructTmp.DataPath.(computerID); % Assign default
end

if doWrite
    writeJSON(projectStruct);
end