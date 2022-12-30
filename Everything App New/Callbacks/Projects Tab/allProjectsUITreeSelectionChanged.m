function []=allProjectsUITreeSelectionChanged(src)

%% PURPOSE: UPDATE THE DATA & PROJECT PATHS, AND THE CURRENTLY SELECTED PROJECT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

projectNode=handles.Projects.allProjectsUITree.SelectedNodes;

if isempty(projectNode)
    return;
end

classVar=getappdata(fig,'Project');

idx=ismember({classVar.Text},projectNode.Text);

assert(any(idx));

% if ~classVar(idx).Checked
%     assert(~ismember(projectNode,handles.Projects.allProjectsUITree.CheckedNodes));
%     return;
% end

computerID=getComputerID();

dataPath=classVar(idx).DataPath.(computerID);
if isempty(dataPath)
    dataPath='Data Path (contains ''Raw Data Files'' folder)';
end

projectPath=classVar(idx).ProjectPath.(computerID);
if isempty(projectPath)
    projectPath='Path to Project Folder';
end

handles.Projects.dataPathField.Value=dataPath;

handles.Projects.projectPathField.Value=projectPath;