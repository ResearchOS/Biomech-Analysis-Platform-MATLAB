function [uiTree]=getUITreeFromNode(node)

%% PURPOSE: RETRIEVES THE UITREE HANDLE FROM THE CURRENTLY SELECTED NODE.
% NOTE THAT NODES CAN ONLY BE CHILDREN OF THE TREE, OR CHILDREN OF ITS CHILDREN. NO MORE THAN 2 LEVELS OF NODES!

if isequal(class(node.Parent),'matlab.ui.container.CheckBoxTree')
    uiTree=node.Parent;
else
    uiTree=node.Parent.Parent;
end