function []=allProjectsUITreeSelectionChanged(src)

%% PURPOSE: UPDATE THE DATA & PROJECT PATHS FOR THE CURRENTLY SELECTED PROJECT NODE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

projectNode=handles.Projects.allProjectsUITree.SelectedNodes;

if isempty(projectNode)
    return;
end

struct = loadJSON(projectNode.NodeData.UUID);

computerID=getComputerID();

dataPath=struct.DataPath.(computerID);

if isempty(dataPath)
    dataPath='Data Path (contains ''Raw Data Files'' folder)';
end

projectPath=struct.ProjectPath.(computerID);

if isempty(projectPath)
    projectPath='Path to Project Folder';
end

handles.Projects.dataPathField.Value=dataPath;

handles.Projects.projectPathField.Value=projectPath;