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
    ordStruct.NULL.Contains.(prUUID).Contains = [];
    ordStruct.NULL.Contains.(prUUID).PrettyName = getName(prUUID);
else
    % Get all of the group and function names in the group
    [runList, containerList] = getRunList(pgUUID);   
    ordStruct = orderedList2Struct(runList, containerList);
end

pgStruct=loadJSON(pgUUID);

handles.Process.currentGroupLabel.Text = [pgStruct.Name ' ' pgUUID];

delete(uiTree.Children);

topLevel = fieldnames(ordStruct);
if isempty(topLevel)
    return;
end

ordStruct = ordStruct.(topLevel{1}).Contains;

fldNames = fieldnames(ordStruct);

for i=1:size(fldNames,1)
    uuid = fldNames{i};
    prettyName = ordStruct.(uuid).PrettyName;

    addNewNode(uiTree, uuid, prettyName, '', ordStruct.(uuid).Contains);    

end

%% Select the corresponding node in the UI tree
selectNode(handles.Process.groupUITree, prUUID);
% if ~isempty(prUUID)
%     selectNode(handles.Process.groupUITree, runList{end,1}); % Can't select a processing group.
% else
% 
% end

%% Select the corresponding processing node in the graph.
obj=get(fig,'CurrentObject');
buttonDownFcn = true;
if ~isequal(class(obj),'matlab.ui.control.UIAxes')
    if ~isempty(prUUID)
        % Get the stack to see if the digraphAxesButtonDownFcn is already
        % on the call stack
        st = dbstack();
        if ~any(contains({st.name},'digraphAxesButtonDownFcn'))
            buttonDownFcn = false;
            digraphAxesButtonDownFcn(src, prUUID);
        end
    end
end

groupUITreeSelectionChanged(fig, buttonDownFcn);