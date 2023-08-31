function [proceed]=deleteNode(selNode)

%% PURPOSE: DELETE THE SELECTED NODE, AND UPDATE THE OTHER CURRENT UI TREES ACCORDINGLY, AS NECESSARY.

proceed = true;
if isempty(selNode)
    return;
end

fig=ancestor(selNode,'figure','toplevel');
handles=getappdata(fig,'handles');

anNode = getNode(handles.Process.analysisUITree, selNode.NodeData.UUID);
selectNeighborNode(anNode,'before');
delete(anNode);

fillAnalysisUITree(fig);