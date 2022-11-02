function []=assignFcnButtonPushed(src,event)

%% PURPOSE: ASSIGN A FUNCTION TO SUMMARIZE THE CURRENT VARIABLE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Stats=getappdata(fig,'Stats');

if isempty(handles.Stats.tablesUITree.SelectedNodes)
    return;
end

if isempty(handles.Stats.fcnsUITree.SelectedNodes)
    return;
end

selNode=handles.Stats.assignedVarsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

if isequal(class(selNode.Parent),'matlab.ui.container.Tree')
    disp('Must select the variable name!');
    return;
end

if isequal(selNode.Parent.Text,'Repetition')
    disp('Must select a data variable!');
    return;
end

if ~isempty(selNode.Children)
    disp('Remove the current function for this variable first!');
    return;
end

% currVar=selNode.Text;

tableName=handles.Stats.tablesUITree.SelectedNodes.Text;

varIdx=ismember(selNode.Parent.Children,selNode);

fcnName=handles.Stats.fcnsUITree.SelectedNodes.Text;

Stats.Tables.(tableName).DataColumns(varIdx).Function=fcnName;

setappdata(fig,'Stats',Stats);

makeAssignedVarsNodes(fig,Stats,tableName);

