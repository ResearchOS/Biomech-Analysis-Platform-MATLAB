function []=fillUITree_PS(fig, class, uiTree, anAbs)

%% PUEPOSE: FILL IN THE CLASS UI TREE WITH PROJECT-SPECIFIC NODES, WITH PARENT NODES THAT ARE PROJECT-INDEPENDENT

handles=getappdata(fig,'handles');

if isempty(uiTree.Children)
    return;
end

tmp=[uiTree.Children.NodeData];
uuids = {tmp.UUID};

% The project-specific class instances
tablename = getTableName(class, true);
sqlquery = ['SELECT UUID, Name FROM ' tablename ';'];
t = fetchQuery(sqlquery);

if isempty(t.UUID)
    return;
end

instUUIDs = t.UUID;
instNames = t.Name;

inAnIdx = contains(instUUIDs, anAbs); % The indices of the instances matching abstract objects in this analysis.
instUUIDs(~inAnIdx) = [];
instNames(~inAnIdx) = [];

[abbrevs, abstractIDs, instanceIDs] = deText(instUUIDs);

abstractUUIDs = genUUID(abbrevs, abstractIDs);

for i=1:length(instUUIDs)
        
    instanceUUID = instUUIDs{i};
    abstractUUID = abstractUUIDs{i};
    idx=ismember(uuids, abstractUUID); % The abstract node idx

    if ~any(idx)
        continue; % There are no abstract nodes for this object. This is an error!
    end

    abstractNode = uiTree.Children(idx); % The abstract node

    newNode = addNewNode(abstractNode, instanceUUID, instNames{i});

    assignContextMenu(newNode,handles);

end