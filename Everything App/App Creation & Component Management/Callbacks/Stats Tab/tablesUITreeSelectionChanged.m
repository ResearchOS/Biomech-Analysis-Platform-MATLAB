function []=tablesUITreeSelectionChanged(src,event)

%% PURPOSE: UPDATE THE ASSIGNEDVARSUITREE WITH THE CURRENTLY SELECTED STATS TABLES' VARS
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Stats=getappdata(fig,'Stats');

if isempty(handles.Stats.tablesUITree.SelectedNodes)
    delete(handles.Stats.assignedVarsUITree.Children);
    return;
end

tableName=handles.Stats.tablesUITree.SelectedNodes.Text;

makeAssignedVarsNodes(fig,Stats,tableName);