function []=createProcessGroupNode(parentNode,uuid,handles)

%% PURPOSE: CREATE NODES FOR ALL MEMBERS OF A PROCESS GROUP IN THE CURRENT GROUP UI TREE

groupStruct=loadJSON(uuid);

uuids=groupStruct.RunList;

% Get texts from UUID's
% uiTree = getUITreeFromNode(parentNode);
% texts=getTextsFromUUID(uuids, uiTree);

for i=1:length(uuids)
    uuid = uuids{i};
    struct = loadJSON(uuid);

    newNode = addNewNode(parentNode, uuid, struct.Text);    

    [abbrev] = deText(uuid);

    if isequal(abbrev,'PG') % Process group
        createProcessGroupNode(newNode,uuid,handles);  
    end    

end