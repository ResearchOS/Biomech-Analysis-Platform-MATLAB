function []=fillProcessGroupUITree(src, prUUID)

%% PURPOSE: FILL THE CURRENT GROUP UI TREE.
% If a group is selected in the current analysis UI tree, then put in all
% the elements of the group.
% If a function is selected, then just put in that function.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

groupNode = handles.Process.analysisUITree.SelectedNodes;

if isempty(groupNode)
    return;
end

initUUID = groupNode.NodeData.UUID;
struct=loadJSON(initUUID);

[initAbbrev] = deText(initUUID);

handles.Process.currentGroupLabel.Text = [struct.Text ' ' initUUID];

uiTree=handles.Process.groupUITree;
delete(uiTree.Children);
if isequal(initAbbrev,'PG')
    list = struct.RunList;
elseif isequal(initAbbrev,'PR')
    list = {initUUID};
end

for i=1:length(list)
    uuid = list{i};

    struct = loadJSON(uuid);
    newNode=uitreenode(uiTree,'Text',struct.Text);
    newNode.NodeData.UUID = uuid;
    assignContextMenu(newNode,handles);

    [abbrev] = deText(uuid);

    if isequal(abbrev,'PG') % ProcessGroup
        uuids = createProcessGroupNode(newNode,uuid,handles);
    end  

end

% if isequal(initAbbrev,'PR') % Process
if nargin == 1 && ~isequal(initAbbrev,'PG')
    selectNode(handles.Process.groupUITree,uuids{end}); % Can't select a processing group.
else
    selectNode(handles.Process.groupUITree, prUUID);
end
groupUITreeSelectionChanged(fig);
% end