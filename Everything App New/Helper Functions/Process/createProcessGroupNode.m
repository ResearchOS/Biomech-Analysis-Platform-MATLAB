function []=createProcessGroupNode(parentNode,text,handles)

%% PURPOSE: CREATE NODES FOR ALL MEMBERS OF A PROCESS GROUP IN THE CURRENT GROUP UI TREE

currGroupPath=getClassFilePath(text,'ProcessGroup');
currGroupStruct=loadJSON(currGroupPath);

texts=currGroupStruct.ExecutionListNames;
types=currGroupStruct.ExecutionListTypes;

for i=1:length(texts)

    newNode=uitreenode(parentNode,'Text',texts{i});
    newNode.NodeData.Class=types{i};
    assignContextMenu(newNode,handles);

    if ~isequal(types{i},'ProcessGroup')
        continue;
    end

    createProcessGroupNode(newNode,texts{i});  

end