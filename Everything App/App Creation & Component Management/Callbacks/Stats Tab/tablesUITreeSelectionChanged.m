function []=tablesUITreeSelectionChanged(src,event)

%% PURPOSE: UPDATE THE ASSIGNEDVARSUITREE WITH THE CURRENTLY SELECTED STATS TABLES' VARS
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Stats=getappdata(fig,'Stats');

if isempty(handles.Stats.tablesUITree.SelectedNodes)
    return;
end

tableName=handles.Stats.tablesUITree.SelectedNodes.Text;

delete(handles.Stats.assignedVarsUITree.Children);

repNode=uitreenode(handles.Stats.assignedVarsUITree,'Text','Repetition');
dataNode=uitreenode(handles.Stats.assignedVarsUITree,'Text','Data');

if isfield(Stats.Tables.(tableName),'RepetitionColumns')
    for i=1:length(Stats.Tables.(tableName).RepetitionColumns)
        uitreenode(repNode,'Text',Stats.Tables.(tableName).RepetitionColumns(i).Name);
    end
end

if isfield(Stats.Tables.(tableName),'DataColumns')
    for i=1:length(Stats.Tables.(tableName).DataColumns)
        uitreenode(dataNode,'Text',Stats.Tables.(tableName).DataColumns(i).Name);
    end
end