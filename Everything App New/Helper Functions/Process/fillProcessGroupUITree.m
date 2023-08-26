function []=fillProcessGroupUITree(src, prUUID, pgUUID)

%% PURPOSE: FILL THE CURRENT GROUP UI TREE.
% Check if the specified function is in a group. If so, populate that
% group. If not, just put in that function name. Update the group label to
% reflect the current group name, or no group name.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree = handles.Process.groupUITree;

if isempty(pgUUID) && isempty(prUUID)
    handles.Process.currentGroupLabel.Text = 'Current Group';
    handles.Processs.currentFunctionLabel.Text = 'Current Process';
    delete(uiTree.Children);
    delete(handles.Process.functionUITree.Children);
    return; % Nothing to fill, don't do anything.
end

if isempty(pgUUID) % Function does not belong to a group.
    runList= {prUUID};
    nameList = getName(prUUID);
else
    % Get all of the group and function names in the group
    [runList, nameList] = getRunList(pgUUID);    
end

pgStruct=loadJSON(pgUUID);

handles.Process.currentGroupLabel.Text = [pgStruct.Name ' ' pgUUID];

delete(uiTree.Children);

for i=1:length(runList)
    uuid = runList{i};

    newNode = addNewNode(uiTree, uuid, nameList{i});
    assignContextMenu(newNode,handles);

    [abbrev] = deText(uuid);

    if isequal(abbrev,'PG') % ProcessGroup
        createProcessGroupNode(newNode,uuid,handles);
    end  

end

%% Select the corresponding processing node in the graph.
obj=get(fig,'CurrentObject');
if ~isequal(class(obj),'matlab.ui.control.UIAxes')
    if nargin==2
        digraphAxesButtonDownFcn(src, prUUID);
    end
end

%% Select the corresponding node in the UI tree
if nargin == 2
    if ~isequal(abbrev,'PG')
        selectNode(handles.Process.groupUITree, runList{end}); % Can't select a processing group.
    else
        selectNode(handles.Process.groupUITree, prUUID);
    end
end

groupUITreeSelectionChanged(fig);