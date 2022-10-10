function []=unassignFcnButtonPushed(src,event)

%% UNASSIGN A FUNCTION FROM SUMMARIZING THE CURRENT VARIABLE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Stats=getappdata(fig,'Stats');

if isempty(handles.Stats.tablesUITree.SelectedNodes)
    return;
end

selNode=handles.Stats.assignedVarsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

parentNode=selNode.Parent;

if isequal(class(selNode.Parent),'matlab.ui.container.Tree') || isequal(class(selNode.Parent.Parent),'matlab.ui.container.Tree')
    disp('Must select the variable name!');
    return;
end

currFcn=selNode.Text;

tableName=handles.Stats.tablesUITree.SelectedNodes.Text;

for i=1:length(Stats.Tables.(tableName).DataColumns)
    if isempty(Stats.Tables.(tableName).DataColumns(i).Function)
        Stats.Tables.(tableName).DataColumns(i).Function='';
    end
end

% fcnIdx=ismember({Stats.Tables.(tableName).DataColumns.Function},currFcn);
fcnIdx=ismember(parentNode.Parent.Children,parentNode);

Stats.Tables.(tableName).DataColumns(fcnIdx).Function='';

setappdata(fig,'Stats',Stats);

makeAssignedVarsNodes(fig,Stats,tableName);