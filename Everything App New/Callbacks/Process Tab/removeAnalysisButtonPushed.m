function []=removeAnalysisButtonPushed(src)

%% PURPOSE: ARCHIVE AN ANALYSIS.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree = handles.Process.allAnalysesUITree;

selNode = uiTree.SelectedNodes;

if isempty(selNode)
    return;
end

uuid = selNode.NodeData.UUID;

Current_Analysis = getCurrent('Current_Analysis');

if isequal(Current_Analysis,'Current_Analysis')
    disp('Cannot remove the current analysis');
    return;
end

moveToArchive(uuid);

selectNeighborNode(selNode);
delete(selNode);

allAnalysesUITreeSelectionChanged(fig);