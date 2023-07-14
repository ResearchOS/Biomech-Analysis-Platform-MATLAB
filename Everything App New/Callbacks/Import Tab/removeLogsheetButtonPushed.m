function []=removeLogsheetButtonPushed(src,event)

%% PURPOSE: REMOVE A LOGSHEET FROM THE LIST

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree=handles.Import.allLogsheetsUITree;

logsheetNode=uiTree.SelectedNodes;

if isempty(logsheetNode)
    return;
end

uuid = logsheetNode.NodeData.UUID;

Current_Logsheet = getCurrent('Current_Logsheet');

if isequal(Current_Logsheet,uuid)
    disp('Cannot remove the current logsheet!');
    return;
end

moveToArchive(uuid);

selectNeighborNode(logsheetNode);
delete(logsheetNode);

allLogsheetsUITreeSelectionChanged(fig);