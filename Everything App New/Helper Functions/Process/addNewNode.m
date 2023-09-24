function [newNode]=addNewNode(parent, uuid, text, doSort, ordStruct)

%% PURPOSE: CREATE A NEW NODE.

if exist('doSort','var')~=1 || isempty(doSort)
    doSort = false;
end

if exist('text','var')~=1 || isempty(text)
    text = 'Default';
end

if isstruct(uuid) % Struct was provided.
    uuid = struct.UUID;
end

if ~ischar(uuid)
    error('Expected UUID as char! Received something else');
end

fig=ancestor(parent,'figure','toplevel');
handles=getappdata(fig,'handles');

[type, abstractID, instanceID] = deText(uuid);

newNode = uitreenode(parent, 'Text', text);
newNode.NodeData.UUID = uuid;
assignContextMenu(newNode,handles);

allUITrees = [handles.Process.allAnalysesUITree; handles.Process.allGroupsUITree; handles.Process.allProcessUITree; handles.Process.allVariablesUITree];
uiTree = getUITreeFromNode(newNode);
% if isequal(type,'PG') && ~ismember(uiTree, allUITrees)
%     createProcessGroupNode(newNode, ordStruct);
% end

if ~ismember(parent,allUITrees)
    return; % No sorting needed.
end

%% WHEN ADDING A NEW ABSTRACT NODE TO THE "ALL" UI TREES, NEED TO SORT THEM PROPERLY.
uiTree = getUITreeFromNode(newNode);
uiTreeClass = getClassFromUITree(uiTree);
switch uiTreeClass
    case 'Analysis'
        plural = 'Analyses';
    case 'ProcessGroup'
        plural = 'Groups';
    case 'Process'
        plural = 'Process';
    case 'Variable'
        plural = 'Variables';
end
sortMethod = handles.Process.(['sort' plural 'DropDown']).Value;
if doSort
    sortUITree(uiTree, sortMethod);
end