function []=assignGroupButtonPushed(src)

%% PURPOSE: ASSIGN PROCESSING GROUP TO THE CURRENT ANALYSIS OR GROUP, DEPENDING WHICH TAB I AM ON.
% What do I need to assign the group?
% 1. What container is it being assigned to?
%   - Analysis, or Group. Depends on:
%       - Which current UI tree tab is selected.
%           - Group: Put the group into the currently selected group. If no
%           group returned from currentProcessGroup, abort.
%           - Analysis: (maybe) ask the user if they want to
%       add it to the group or the analysis.
% 2. If there are any other PR/groups that are upstream dependencies and
% are missing from the analysis/group, then pull those in too.

fig=ancestor(src,'figure','toplevel'); 
handles=getappdata(fig,'handles');

selNode=handles.Process.allGroupsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

selUUID = selNode.NodeData.UUID;

[type, abstractID, instanceID] = deText(selUUID);

currTab = handles.Process.subtabCurrent.SelectedTab;
tabTitle = currTab.Title;
containerUUID = getContainer(currTab);

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

isDupl = linkObjs(selUUID, containerUUID);
if isDupl
    return; % Don't worry about deleting a newly created instance, because if a new instance were created, it wouldn't be a duplicate.
end

if isequal(tabTitle,'Analysis')
    fillAnalysisUITree(fig);
    uiTree = handles.Process.analysisUITree;
    selectNode(uiTree, selUUID);
end
fillProcessGroupUITree(fig, '', selUUID);

delete(handles.Process.functionUITree.Children);
handles.Process.currentFunctionLabel.Text = 'Current Function';