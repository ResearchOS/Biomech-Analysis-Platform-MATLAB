function []=fillAnalysisUITree(src)

%% PURPOSE: FILL THE CURRENT ANALYSIS UI TREE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Current_Analysis = getCurrent('Current_Analysis');
anStruct = loadJSON(Current_Analysis);

list = anStruct.RunList;
% texts = getTextsFromUUID(list,handles.Process.allGroupsUITree);

uiTree = handles.Process.analysisUITree;

% Delete all existing entries in current UI trees.
delete(uiTree.Children);
delete(handles.Process.groupUITree.Children);
delete(handles.Process.functionUITree.Children);
handles.Process.currentGroupLabel.Text = 'Current Group';
handles.Process.currentFunctionLabel.Text = 'Current Process';

for i=1:length(list)
    uuid = list{i};

    % Load every file to read its text. Slow! Should be improved in the
    % future.
    struct = loadJSON(uuid);

    newNode = uitreenode(uiTree,'Text',struct.Text);
    newNode.NodeData.UUID = uuid;
    assignContextMenu(newNode,handles);

    [abbrev] = deText(uuid);

    if isequal(abbrev,'PG') % ProcessGroup
        createProcessGroupNode(newNode,uuid,handles);
    end

end

handles.Process.subtabCurrent.SelectedTab = handles.Process.currentAnalysisTab;