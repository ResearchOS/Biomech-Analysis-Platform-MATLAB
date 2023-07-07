function []=createProcessGroupNode(parentNode,uuid,handles)

%% PURPOSE: CREATE NODES FOR ALL MEMBERS OF A PROCESS GROUP IN THE CURRENT GROUP UI TREE

groupStruct=loadJSON(uuid);

uuids=groupStruct.RunList;

% Get texts from UUID's
uiTree = getUITreeFromNode(parentNode);
texts=getTextsFromUUID(uuids, uiTree);

for i=1:length(uuids)

    newNode=uitreenode(parentNode,'Text',texts{i});
    newNode.NodeData.UUID=uuids{i};
    assignContextMenu(newNode,handles);

    if isequal(abbrev,'PG') % Process group
        createProcessGroupNode(newNode,uuids{i},handles);  
    end    

end