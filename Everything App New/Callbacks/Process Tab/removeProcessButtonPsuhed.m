function []=removeProcessButtonPsuhed(src,event)

%% PURPOSE: REMOVE A PROCESSING FUNCTION FROM THE LIST

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree = handles.Process.allProcessUITree;

selNode = uiTree.SelectedNodes;

if isempty(selNode)
    return;
end

uuid = selNode.NodeData.UUID;

currNode = getNode(handles.Process.analysisUITree, uuid);

if ~isempty(currNode)
    disp('Cannot archive a process function that is being used in the current analysis!');
    return;
end

moveToArchive(uuid);

selectNeighborNode(selNode);
delete(selNode);