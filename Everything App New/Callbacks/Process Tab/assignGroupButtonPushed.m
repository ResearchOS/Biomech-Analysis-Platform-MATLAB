function []=assignGroupButtonPushed(src)

%% PURPOSE: ASSIGN PROCESSING GROUP TO THE CURRENT ANALYSIS OR GROUP, DEPENDING WHICH TAB I AM ON.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Process.allGroupsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

selUUID = selNode.NodeData.UUID;

[type, abstractID, instanceID] = deText(selUUID);

% Abstract selected. Create new instance.
if isempty(instanceID)
    % Confirm that the user wants to create a new instance
    a = questdlg('Are you sure you want to create a new instance of this object?','Confirm','No');
    if ~isequal(a,'Yes')
        return;
    end
    pgStruct = createNewObject(true, 'ProcessGroup', selNode.Text, abstractID, '', true);
    selUUID = pgStruct.UUID;
    abstractUUID = genUUID(type, abstractID);
    absNode = selectNode(handles.Process.allGroupsUITree, abstractUUID);

    % Create the new node in the "all" UI tree
    addNewNode(absNode, selUUID, pgStruct.Text);
end

[containerUUID, uiTree] = getContainer(fig);
contStruct = loadJSON(containerUUID);
contStruct.RunList = [contStruct.RunList; {selUUID}];
writeJSON(getJSONPath(contStruct), contStruct);
selStruct = loadJSON(selUUID);

% Add a new node to the current UI tree
addNewNode(uiTree, selStruct.UUID, selStruct.Text);
selectNode(uiTree, selStruct.UUID);

switch uiTree
    case handles.Process.groupUITree
        fillCurrentFunctionUITree(fig);
    case handles.Process.analysisUITree
        fillProcessGroupUITree(fig); % Added group to analysis. Completely refill the current process group UI tree
    otherwise
        error('Where am I?');
end