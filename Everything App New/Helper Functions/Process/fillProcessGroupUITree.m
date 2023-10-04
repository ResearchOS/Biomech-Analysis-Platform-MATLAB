function []=fillProcessGroupUITree(src, prUUID, pgUUID)

%% PURPOSE: FILL THE CURRENT GROUP UI TREE.
% Check if the specified function is in a group. If so, populate that
% group. If not, just put in that function name. Update the group label to
% reflect the current group name, or no group name.

global globalG;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree = handles.Process.groupUITree;

delete(uiTree.Children);
delete(handles.Process.functionUITree.Children);
handles.Process.currentFunctionLabel.Text = 'Current Process'; 

if isempty(pgUUID) && isempty(prUUID)
    handles.Process.currentGroupLabel.Text = 'Current Group';      
    return; % Nothing to fill, don't do anything.
end

if isempty(pgUUID) % Function does not belong to a group.
    addNewNode(uiTree, prUUID, getName(prUUID));
else
    % Get all of the group and function names in the group
    tmpG = getSubgraph(globalG, pgUUID, 'up');
    orderedEdges = orderedList2Struct(tmpG);
    fillAN_PG_UITree(uiTree, handles, orderedEdges);
end

%% Select the corresponding node in the UI tree
selectNode(handles.Process.groupUITree, prUUID);

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