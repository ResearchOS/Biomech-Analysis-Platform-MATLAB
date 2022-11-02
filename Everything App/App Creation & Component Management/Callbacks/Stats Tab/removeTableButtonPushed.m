function []=removeTableButtonPushed(src,event)

%% PURPOSE: REMOVE A STATS TABLE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Stats=getappdata(fig,'Stats');

if isempty(handles.Stats.tablesUITree.SelectedNodes)
    return;
end

tableName=handles.Stats.tablesUITree.SelectedNodes.Text;

Stats.Tables=rmfield(Stats.Tables,tableName);

setappdata(fig,'Stats',Stats);

tableNames=fieldnames(Stats.Tables);
makeTableNodes(fig,1:length(tableNames),tableNames);

tablesUITreeSelectionChanged(fig);

