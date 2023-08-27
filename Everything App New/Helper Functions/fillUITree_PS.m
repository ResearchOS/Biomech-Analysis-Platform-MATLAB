function []=fillUITree_PS(fig, class, uiTree)

%% PUEPOSE: FILL IN THE CLASS UI TREE WITH PROJECT-SPECIFIC NODES, WITH PARENT NODES THAT ARE PROJECT-INDEPENDENT
global conn;

handles=getappdata(fig,'handles');

if isempty(uiTree.Children)
    return;
end

tmp=[uiTree.Children.NodeData];
uuids = {tmp.UUID};

% The project-specific class instances
tablename = getTableName(class, true);
sqlquery = ['SELECT UUID, Name FROM ' tablename ';'];
t = fetch(conn,sqlquery);
zIdx = ismember(t.UUID,'ZZZZZZ_ZZZ');
t(zIdx,:) = [];

instUUIDs = cellstr(t.UUID);
instNames = cellstr(t.Name);
[abbrevs, abstractIDs, instanceIDs] = deText(instUUIDs);

for i=1:length(instUUIDs)
        
    instanceUUID = genUUID(class, abstractIDs{i}, instanceIDs{i});
    abstractUUID = genUUID(class, abstractIDs{i});
    idx=ismember(uuids, abstractUUID); % The abstract node idx

    if ~any(idx)
        continue; % There are no abstract nodes for this object. This is an error!
    end

    abstractNode = uiTree.Children(idx); % The abstract node

    if ~isempty(abstractNode.Children)
        tmp = [abstractNode.Children.NodeData];
        existInstanceUUID = {tmp.UUID}; % UUID's of already-existing nodes.
    else
        existInstanceUUID = {};
    end

    existIdx = ismember(instanceUUID, existInstanceUUID);

    if existIdx
        continue;
    end

    newNode = addNewNode(abstractNode, instanceUUID, instNames{i});

    assignContextMenu(newNode,handles);

end