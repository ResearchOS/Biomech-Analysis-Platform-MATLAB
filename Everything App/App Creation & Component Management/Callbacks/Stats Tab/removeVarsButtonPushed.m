function []=removeVarsButtonPushed(src,event)

%% PURPOSE: REMOVE A REPETITION OR DATA VARIABLE FROM THE ASSIGNED VARS UI TREE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Stats=getappdata(fig,'Stats');

if isempty(handles.Stats.tablesUITree.SelectedNodes)
    return;
end

selNode=handles.Stats.assignedVarsUITree.SelectedNodes;

if isequal(class(selNode.Parent),'matlab.ui.container.Tree')
    disp('Select a variable, not a category!');
    return;
end

if ~ismember(selNode.Parent.Text,{'Data','Repetition'})
    disp('Select a variable, not its function!');
    return;
end

varName=selNode.Text;

tableName=handles.Stats.tablesUITree.SelectedNodes.Text;

cat=selNode.Parent.Text;

% Remove the variable from the struct.
varNames={Stats.Tables.(tableName).([cat 'Columns']).Name};

varIdx=ismember(varNames,varName);

Stats.Tables.(tableName).([cat 'Columns'])=Stats.Tables.(tableName).([cat 'Columns'])(~varIdx); % Remove the variable

setappdata(fig,'Stats',Stats);

makeAssignedVarsNodes(fig,Stats,tableName);

