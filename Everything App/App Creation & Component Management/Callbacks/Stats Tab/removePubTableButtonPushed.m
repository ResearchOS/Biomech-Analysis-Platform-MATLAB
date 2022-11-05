function []=removePubTableButtonPushed(src,event)

%% PURPOSE: REMOVE A PUBLICATION TABLE FROM THE LIST.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Stats=getappdata(fig,'Stats');

tableName=handles.Stats.pubTablesUITree.SelectedNodes.Text;

Stats.PubTables=rmfield(Stats.PubTables,tableName);

tableNames=fieldnames(Stats.PubTables);

setappdata(fig,'Stats',Stats);

makePubTableNodes(fig,1:length(tableNames),tableNames);