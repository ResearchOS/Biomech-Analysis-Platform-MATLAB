function [projectStruct]=newComputerProjectPaths(pjUUID)

%% PURPOSE: ENSURE THAT THERE ARE FIELDS FOR THE COMPUTER-SPECIFIC PATHS

computerID = getComputerID();

projectStruct = loadJSON(pjUUID);
pjStructTmp = createNewObject(true,'Project','Default','','',false);

doWrite = false;
if ~isfield(projectStruct,'Project_Path') || ~isfield(projectStruct.Project_Path,computerID)
    doWrite = true;
    projectStruct.Project_Path.(computerID) = pjStructTmp.Project_Path.(computerID); % Assign default
end

if ~isfield(projectStruct,'Data_Path') || ~isfield(projectStruct.Data_Path,computerID)
    doWrite = true;
    projectStruct.Data_Path.(computerID) = pjStructTmp.Data_Path.(computerID); % Assign default
end

if doWrite
    writeJSON(projectStruct);
end