function []=addRepsVarButtonPushed(src,event)

%% PURPOSE: ADD A REPETITION VARIABLE TO THE STATS TABLE
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

if ~isfield(Stats.Tables.(tableName),'RepetitionColumns') || isempty(Stats.Tables.(tableName).RepetitionColumns)
    repNum=1;
else
    repNum=length(Stats.Tables.(tableName).RepetitionColumns)+1;
end

Stats.Tables.(tableName).RepetitionColumns(repNum).Name=[currVar ' (' splitCode ')'];

setappdata(fig,'Stats',Stats);

makeAssignedVarsNodes(fig,Stats,tableName);

