function []=removeGroupButtonPushed(src,event)

%% PURPOSE: REMOVE A PROCESSING FUNCTION GROUP

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree = handles.Process.allProcessGroupsUITree;

selNode = uiTree.SelectedNodes;

if isempty(selNode)
    return;
end

uuid = selNode.NodeData.UUID;

currNode = getNode(handles.Process.analysisUITree, uuid);

if ~isempty(currNode)
    disp('Cannot archive a group that is being used in the current analysis!');
    return;
end

moveToArchive(uuid);

selectNeighborNode(selNode);
delete(selNode);

% allGroupsUITreeSelectionChanged(fig);