function []=allProjectsUITreeSelectionChanged(src)

%% PURPOSE: UPDATE THE DATA & PROJECT PATHS, AND THE CURRENTLY SELECTED PROJECT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

projectNode=handles.Projects.allProjectsUITree.SelectedNodes;

if isempty(projectNode)
    return;
end

fullPath=getClassFilePath(projectNode);

struct=loadJSON(fullPath);

computerID=getComputerID();

if ~isfield(struct.DataPath,computerID)
    dataPath='Data Path (contains ''Raw Data Files'' folder)';
else
    dataPath=struct.DataPath.(computerID);
end

if isempty(dataPath)
    dataPath='Data Path (contains ''Raw Data Files'' folder)';
end

if ~isfield(struct.ProjectPath,computerID)
    projectPath='Path to Project Folder';
else
    projectPath=struct.ProjectPath.(computerID);
end

if isempty(projectPath)
    projectPath='Path to Project Folder';
end

handles.Projects.dataPathField.Value=dataPath;

handles.Projects.projectPathField.Value=projectPath;