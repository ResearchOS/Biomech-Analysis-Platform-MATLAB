function []=addDataRepVarsButtonPushed(src,event)

%% PURPOSE: ADD REPETITION VARIABLES BASED ON THE DATA. THIS IS NEEDED WHEN THERE IS MORE THAN ONE VALUE PER TRIAL
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Stats=getappdata(fig,'Stats');

tableNode=handles.Stats.tablesUITree.SelectedNodes;

if isempty(tableNode)
    return;
end

selNode=handles.Stats.assignedVarsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

tableName=tableNode.Text;

parentNode=selNode.Parent;

if isequal(class(parentNode),'matlab.ui.container.Tree')
    disp('Select a variable, not a category!');
    return;
end

if ~ismember(parentNode.Text,{'Data','Repetition'})
    disp('Select a variable, not its function!');
    return;
end

varNames={Stats.Tables.(tableName).DataColumns.GUINames};

Stats.Tables.(tableName).DataColumns