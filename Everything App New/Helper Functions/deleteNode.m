function [proceed]=deleteNode(selNode)

%% PURPOSE: DELETE THE SELECTED NODE, AND UPDATE THE OTHER CURRENT UI TREES ACCORDINGLY, AS NECESSARY.

proceed = true;
if isempty(selNode)
    return;
end

fig=ancestor(selNode,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree = getUITreeFromNode(selNode);

selectNeighborNode(selNode,'before');

%% Removing something from the analysis or processGroup UI tree
if isequal(uiTree,handles.Process.analysisUITree)    
    fillProcessGroupUITree(fig);
end

if isequal(uiTree, handles.Process.groupUITree)
    anNode = getNode(handles.Process.analysisUITree, selNode.NodeData.UUID);
    delete(anNode);
    fillCurrentFunctionUITree(fig);
end

delete(selNode);