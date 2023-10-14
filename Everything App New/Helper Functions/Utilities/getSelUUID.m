function [uuid] = getSelUUID(uiTree)

%% PURPOSE: RETURN THE UUID OF THE SELECTED NODE IN THE PARENT.

uuid = '';

selNode = uiTree.SelectedNodes;

if isempty(selNode)
    return;
end

uuid = selNode.NodeData.UUID;