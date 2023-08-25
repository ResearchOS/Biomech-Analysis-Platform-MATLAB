function [uuids]=createProcessGroupNode(parentNode,uuid,handles)

%% PURPOSE: CREATE NODES FOR ALL MEMBERS OF A PROCESS GROUP IN THE CURRENT GROUP UI TREE

[uuids, names] = getRunList(uuid);

for i=1:length(uuids)
    uuid = uuids{i};

    newNode = addNewNode(parentNode, uuid, names{i});    

    [abbrev] = deText(uuid);

    if isequal(abbrev,'PG') % Process group
        createProcessGroupNode(newNode,uuid,handles);  
    end    

end