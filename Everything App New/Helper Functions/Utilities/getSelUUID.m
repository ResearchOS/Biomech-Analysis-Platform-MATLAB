function [uuid] = getSelUUID(uiTree)

%% PURPOSE: RETURN THE UUID OF THE SELECTED NODE IN THE PARENT.

uuid = '';

checkedNodes = uiTree.CheckedNodes;
selNode = uiTree.SelectedNodes;

if isempty(checkedNodes) && isempty(selNode)
    return;
end

if isempty(checkedNodes)
    nodes = selNode;
else
    nodes = checkedNodes;
end

tmp= [nodes.NodeData];
uuid = {tmp.UUID};

if length(uuid)==1
    uuid = uuid{1};
end