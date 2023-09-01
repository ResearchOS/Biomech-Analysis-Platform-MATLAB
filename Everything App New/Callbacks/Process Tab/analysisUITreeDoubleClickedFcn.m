function []=analysisUITreeDoubleClickedFcn(src)

%% PURPOSE: AFTER DOUBLE CLICK, NAVIGATE TO THE SELECTED NODE'S UI TREE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode = handles.Process.analysisUITree.SelectedNodes;

if isempty(selNode)
    return;
end

uuid = selNode.NodeData.UUID;
type = deText(uuid);

if contains(type,'PG')
    handles.Process.subtabCurrent.SelectedTab = handles.Process.currentGroupTab;
    return;
end

% Select the node in the digraph and render it.
digraphAxesButtonDownFcn(fig, uuid);

% Pass focus to function UI tree
handles.Process.subtabCurrent.SelectedTab = handles.Process.currentFunctionTab;

subTabCurrentSelectionChanged(fig);