function []=allProjectsUITreeSelectionChanged(src)

%% PURPOSE: UPDATE THE DATA & PROJECT PATHS FOR THE CURRENTLY SELECTED PROJECT NODE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

projectNode=handles.Projects.allProjectsUITree.SelectedNodes;

if isempty(projectNode)
    return;
end

uuid = projectNode.NodeData.UUID;

[type, abstractID, instanceID] = deText(uuid);

if ~isempty(instanceID)
    % Ensure that the current computer's ID field is present.
    struct = newComputerProjectPaths(uuid);
    computerID = getCurrent('Computer_ID');
    dataPath=struct.Data_Path.(computerID);
    projectPath=struct.Project_Path.(computerID);
else
    dataPath = '';
    projectPath = '';
end

if isempty(dataPath)
    dataPath='Data Path (contains ''Raw Data Files'' folder)';
end

if isempty(projectPath)
    projectPath='Path to Project Folder';
end

handles.Projects.dataPathField.Value=dataPath;

handles.Projects.projectPathField.Value=projectPath;