function []=fillAnalysisUITree(src)

%% PURPOSE: FILL THE CURRENT ANALYSIS UI TREE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Current_Analysis = getCurrent('Current_Analysis');
anStruct = loadJSON(Current_Analysis);

list = anStruct.RunList;
texts = getTextsFromUUID(list,handles.Process.allGroupsUITree);

uiTree = handles.Process.analysisUITree;

for i=1:length(list)
    uuid = list{i};

    newNode = uitreenode(uiTree,'Text',texts{i});
    newNode.NodeData.UUID = uuid;
    assignContextMenu(newNode,handles);

    [abbrev] = deText(uuid);

    if isequal(abbrev,'PG') % ProcessGroup
        createProcessGroupNode(newNode,uuid,handles);
    end

end