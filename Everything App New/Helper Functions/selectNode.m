function [selNode]=selectNode(uiTree,uuid)

%% PURPOSE: SELECT THE NODE WITH THE CORRESPONDING UUID.

if isempty(uuid)
    selNode=[];
    uiTree.SelectedNodes=selNode;
    return;
end

selNode = getNode(uiTree, uuid); % The heavy lifting to select the proper node.
if isempty(selNode)
    return;
end
uiTree.SelectedNodes=selNode;

% Expand the parents of this node.
while isequal(class(selNode),class(selNode.Parent))
    selNode = selNode.Parent;
end

expand(selNode);