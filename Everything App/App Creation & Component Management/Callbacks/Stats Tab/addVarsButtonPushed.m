function []=addVarsButtonPushed(src,event)

%% PURPOSE: ADD DATA VARIABLE TO THE STATS TABLE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Stats=getappdata(fig,'Stats');

if isempty(handles.Stats.tablesUITree.SelectedNodes)
    return;
end

if isempty(handles.Stats.varsUITree.SelectedNodes)
    return;
end

selNode=handles.Stats.varsUITree.SelectedNodes;

if isequal(class(selNode.Parent),'matlab.ui.container.Tree')
    disp('Select the variable split, not the variable itself!');
    return;
end

currVar=selNode.Parent.Text;
currSplit=selNode.Text;
spaceIdx=strfind(currSplit,' ');
splitName=currSplit(1:spaceIdx-1);
splitCode=currSplit(spaceIdx+2:end-1);

tableName=handles.Stats.tablesUITree.SelectedNodes.Text;

% reps=Stats.Tables.(tableName).RepetitionColumns;
if ~isfield(Stats.Tables.(tableName),'DataColumns') || isempty(Stats.Tables.(tableName).DataColumns)
    repNum=1;
else
    repNum=length(Stats.Tables.(tableName).DataColumns)+1;
end

Stats.Tables.(tableName).DataColumns(repNum).Name=[currVar ' (' splitCode ')'];

dataNode=findobj(handles.Stats.assignedVarsUITree,'Text','Data');
delete(dataNode.Children);
for i=1:repNum
    a=uitreenode(dataNode,'Text',Stats.Tables.(tableName).DataColumns(repNum).Name);
end

setappdata(fig,'Stats',Stats);