function []=fillUITree_PS(fig, class, uiTree)

%% PUEPOSE: FILL IN THE CLASS UI TREE WITH PROJECT-SPECIFIC NODES, WITH PARENT NODES THAT ARE PROJECT-INDEPENDENT

handles=getappdata(fig,'handles');

if isempty(uiTree.Children)
    return;
end

tmp=[uiTree.Children.NodeData];
uuids = {tmp.UUID};

% The project-specific class instances
filenames=getClassFilenames(class,true);
[abbrevs, abstractIDs, instanceIDs] = deText(filenames);

for i=1:length(filenames)
        
    instanceUUID = genUUID(class, abstractIDs{i}, instanceIDs{i});
    abstractUUID = genUUID(class, abstractIDs{i});
    idx=ismember(uuids, abstractUUID); % The abstract node idx

    if ~any(idx)
        continue; % There are no abstract nodes for this object. This is an error!
    end

    abstractNode = uiTree.Children(idx); % The abstract node

    tmp = [abstractNode.Children.NodeData];
    existInstanceUUID = {tmp.UUID}; % UUID's of already-existing nodes.

    existIdx = ismember(instanceUUID, existInstanceUUID);

    if existIdx
        continue;
    end

    struct = loadJSON(instanceUUID);

    newNode=uitreenode(abstractNode,'Text',struct.Text);
    newNode.NodeData.UUID = struct.UUID;

    assignContextMenu(newNode,handles);

end