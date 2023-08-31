function [uuids]=createProcessGroupNode(parentNode,ordStruct)

%% PURPOSE: CREATE NODES FOR ALL MEMBERS OF A PROCESS GROUP IN THE CURRENT GROUP UI TREE

if isempty(ordStruct)
    ordStruct = struct();
end

uuids = fieldnames(ordStruct);

for i=1:length(uuids)
    uuid = uuids{i};
    text = ordStruct.(uuid).PrettyName;

    newNode = addNewNode(parentNode, uuid, text);    

    [abbrev] = deText(uuid);

    if isequal(abbrev,'PG') % Process group
        createProcessGroupNode(newNode,ordStruct.(uuid).Contains);  
    end    

end