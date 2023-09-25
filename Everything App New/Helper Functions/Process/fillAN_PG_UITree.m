function []=fillAN_PG_UITree(uiTree, handles, ordStruct)

%% PURPOSE: FILL ANALYSIS UI TREE, OR PG UI TREE

% Delete all existing entries in current UI trees.
delete(uiTree.Children);
delete(handles.Process.functionUITree.Children);
handles.Process.currentFunctionLabel.Text = 'Current Process';
delete(handles.Process.groupUITree.Children);
handles.Process.currentGroupLabel.Text = 'Current Group';

if isequal(uiTree, handles.Process.groupUITree)
    selNode = handles.Process.analysisUITree.SelectedNodes;
    uuid = selNode.NodeData.UUID;
    handles.Process.currentGroupLabel.Text = [selNode.Text ' ' uuid];
elseif isequal(uiTree, handles.Process.functionUITree)
    selNode = handles.Process.groupUITree.SelectedNodes;
    uuid = selNode.NodeData.UUID;
    handles.Process.currentFunctionLabel.Text = [selNode.Text ' ' uuid];
end

h = gobjects(size(ordStruct));
uniqueParents = flip(unique(ordStruct(:,2),'stable'));
numUnique = length(uniqueParents);
texts = getName(ordStruct(:,1));
for i=1:numUnique

    currParent = uniqueParents{i};
    parentIdx = ismember(ordStruct(:,2),currParent);
    children = ordStruct(parentIdx,1);
    if isequal(currParent,ordStruct{end,2}) % Top level, so the parent should be the UI tree
        parent = uiTree;
        h(parentIdx,2) = parent;
    else
        parent = unique(h(parentIdx,2));
        assert(length(parent)==1);
    end    
    for j=1:length(children)
        childIdx = ismember(ordStruct(:,1),children{j});
        node = addNewNode(parent, children{j}, texts{childIdx});        
        h(childIdx,1) = node;
        newParentIdx = ismember(ordStruct(:,2),children{j});
        h(newParentIdx,2) = node;
    end
       
end