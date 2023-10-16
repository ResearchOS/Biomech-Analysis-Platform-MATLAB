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
selNode = selNode(1);
uiTree.SelectedNodes=selNode;

% Expand the parents of this node.
selNodeParent = selNode;
while isequal(class(selNodeParent),class(selNodeParent.Parent))
    selNodeParent = selNodeParent.Parent;
end

expand(selNodeParent);