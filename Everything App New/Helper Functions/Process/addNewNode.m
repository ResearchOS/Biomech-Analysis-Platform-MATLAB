function []=addNewNode(parent, uuid, text)

%% PURPOSE: CREATE A NEW NODE.

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

type = deText(uuid);

newNode = uitreenode(parent, 'Text', text);
newNode.NodeData.UUID = uuid;
assignContextMenu(newNode,handles);

if isequal(type,'PG')
    createProcessGroupNode(newNode,uuid,handles);
end

allUITrees = [handles.Process.allAnalysesUITree; handles.Process.allGroupsUITree; handles.Process.allProcessUITree; handles.Process.allVariablesUITree];
if ~ismember(parent,allUITrees)
    return; % No sorting needed.
end

%% WHEN ADDING A NEW ABSTRACT NODE TO THE "ALL" UI TREES, NEED TO PLACE THEM IN THE PROPER PLACE.
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
sortUITree(uiTree, sortMethod);