function []=assignGroupButtonPushed(src)

%% PURPOSE: ASSIGN PROCESSING GROUP TO THE CURRENT ANALYSIS OR GROUP, DEPENDING WHICH TAB I AM ON.
% What do I need to assign the group?
% 1. What container is it being assigned to?
%   - Analysis, or Group. Depends on which current UI tree tab is selected.
%       - Group: Group UI tree. If no group is selected in analysis UI tree, can't be added.
%       - Analysis: Analysis UI tree

fig=ancestor(src,'figure','toplevel'); 
handles=getappdata(fig,'handles');

selNode=handles.Process.allGroupsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

selUUID = selNode.NodeData.UUID;

[type, abstractID, instanceID] = deText(selUUID);

currTab = handles.Process.subtabCurrent.SelectedTab.Title;
switch currTab
    case 'Analysis'
        containerUUID = getCurrent('Current_Analysis');
        uiTree = handles.Process.analysisUITree;        
    case 'Group'
        % Check if there is a group selected in the analysis UI tree
        anTreeNode = handles.Process.allAnalysesUITree.SelectedNodes;
        [~, list] = getUITreeFromNode(anTreeNode);
        pgIdx = find(contains(list,'PG')==1);
        containerUUID = '';
        if ~isempty(pgIdx)
            containerUUID = list(min(pgIdx));
        end
        uiTree = handles.Process.groupUITree;
end

if isempty(containerUUID)
    return;
end

% Abstract selected. Create new instance.
if isempty(instanceID)
    % Confirm that the user wants to create a new instance
    a = questdlg('Are you sure you want to create a new instance of this object?','Confirm','No');
    if ~isequal(a,'Yes')
        return;
    end
    figure(fig);
    pgStruct = createNewObject(true, 'ProcessGroup', selNode.Text, abstractID, '', true);
    selUUID = pgStruct.UUID;
    abstractUUID = genUUID(type, abstractID);
    absNode = selectNode(handles.Process.allGroupsUITree, abstractUUID);

    % Create the new node in the "all" UI tree
    addNewNode(absNode, selUUID, pgStruct.Name);
end

linkObjs(selUUID, containerUUID);
newNode = addNewNode(uiTree, selUUID, selNode.Text);

selectNode(uiTree, newNode);

if isequal(currTab,'Analysis')
    fillProcessGroupUITree(fig, '', selUUID);
end

delete(handles.Process.currentFunctionUITree.Children);
handles.Process.currentFunctionLabel.Text = 'Current Function';