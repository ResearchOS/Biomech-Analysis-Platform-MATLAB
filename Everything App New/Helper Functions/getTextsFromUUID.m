function [texts] = getTextsFromUUID(uuids, uiTree)

%% PURPOSE: GET TEXT FROM UUID BY SEARCHING THROUGH THE CORRESPONDING ALL OBJECTS UI TREE

if isempty(uuids)
    texts={};
    return;
end

if ~iscell(uuids)
    uuids = {uuids};
end

% Get all UUID's from this uitree
tmp = [uiTree.Children.NodeData];
uiTree_uuids = {tmp.UUID};
texts = {uiTree.Children.Text};

[a, b, c] = intersect(uuids, uiTree_uuids);
texts = texts(b); % Should be in same order as uuids