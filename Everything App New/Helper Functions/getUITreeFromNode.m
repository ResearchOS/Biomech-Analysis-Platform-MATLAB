function [uiTree, list]=getUITreeFromNode(node)

%% PURPOSE: RETRIEVES THE UITREE HANDLE FROM THE CURRENTLY SELECTED NODE.

list(1) = node;
uiTree=node.Parent;

while ~isequal(class(uiTree),'matlab.ui.container.CheckBoxTree')
    list(end+1) = uiTree;
    uiTree=uiTree.Parent;
end

list(end+1) = uiTree;