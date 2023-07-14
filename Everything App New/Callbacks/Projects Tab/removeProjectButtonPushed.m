function []=removeProjectButtonPushed(src)

%% PURPOSE: PUT A PROJECT JSON FILE INTO THE ARCHIVE FOLDER.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree=handles.Projects.allProjectsUITree;

projectNode=uiTree.SelectedNodes;

if isempty(projectNode)
    return;
end

uuid = projectNode.NodeData.UUID;

Current_Project_Name = getCurrent('Current_Project_Name');

if isequal(Current_Project_Name,uuid)
    disp('Cannot remove the current project! Select another project to remove this one.');
    return;
end

moveToArchive(uuid);

selectNeighborNode(projectNode);
delete(projectNode);

allProjectsUITreeSelectionChanged(fig);