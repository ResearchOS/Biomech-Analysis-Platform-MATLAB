function []=fillAN_PG_UITree(uiTree, handles, ordStruct)

%% PURPOSE: FILL ANALYSIS UI TREE, OR PG UI TREE

% Delete all existing entries in current UI trees.
delete(uiTree.Children);
delete(handles.Process.groupUITree.Children);
delete(handles.Process.functionUITree.Children);
handles.Process.currentGroupLabel.Text = 'Current Group';
handles.Process.currentFunctionLabel.Text = 'Current Process';

topLevel = fieldnames(ordStruct);
if isempty(topLevel)
    return;
end

assert(length(topLevel)==1);

ordStruct = ordStruct.(topLevel{1}).Contains;

fldNames = fieldnames(ordStruct);

for i=1:length(fldNames)
    prettyName = ordStruct.(fldNames{i}).PrettyName;
    uuid = fldNames{i};

    addNewNode(uiTree, uuid, prettyName, '', ordStruct.(fldNames{i}).Contains);

end