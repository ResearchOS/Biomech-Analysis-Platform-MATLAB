function [uiTree]=getUITreeFromNode(node)

%% PURPOSE: RETRIEVES THE UITREE HANDLE FROM THE CURRENTLY SELECTED NODE.

uiTree=node.Parent;

while ~isequal(class(uiTree),'matlab.ui.container.CheckBoxTree')
    uiTree=uiTree.Parent;
end