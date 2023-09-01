function []=groupUITreeDoubleClicked(src,event)

%% PURPOSE: OPEN THE FUNCTION TAB WHEN A FUNCTION IS DOUBLE CLICKED

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode = handles.Process.groupUITree.SelectedNodes;

if isempty(selNode)
    return;
end

handles.Process.subtabCurrent.SelectedTab = handles.Process.currentFunctionTab;

subTabCurrentSelectionChanged(fig);