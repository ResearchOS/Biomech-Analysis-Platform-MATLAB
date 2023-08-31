function []=assignFunctionButtonPushed(src)

%% PURPOSE: ASSIGN PROCESSING FUNCTION TO THE CURRENT ANALYSIS OR PROCESSING GROUP
% If on Analysis tab, assign function directly to analysis
% If on Group tab, assign function to group. If no group is selected in
% analysis UI tree, can't be added.

% Use case: assign function to analysis
%   1. Clear group UI tree. Update group UI tree label XX
%   2. Add node to group UI tree
%   3. Link function to analysis XX
%   4. Add node to analysis UI tree (in order from RunList)
%   5. Run fillProcessUITree
% Use case: assign function to group
%   1. Link function to group XX
%   2. Add node to analysis UI tree (in order from RunList)
%   3. Add node to group UI tree (in order from RunList)
%   4. Run fillProcessUITree


fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Process.allProcessUITree.SelectedNodes;

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
    prStruct = createNewObject(true, 'Process', selNode.Text, abstractID, '', true);
    selUUID = prStruct.UUID;
    abstractUUID = genUUID(type, abstractID);
    absNode = getNode(handles.Process.allProcessUITree, abstractUUID);

    % Create the new node in the "all" UI tree
    addNewNode(absNode, selUUID, prStruct.Name);
end

isDupl = linkObjs(selUUID, containerUUID);
if isDupl
    return;
end

if isequal(tabTitle,'Analysis')
    fillAnalysisUITree(fig);
    uiTree = handles.Process.analysisUITree;
    selectNode(uiTree, selUUID);
end
pgUUID = getCurrentProcessGroup(fig);
fillProcessGroupUITree(fig,selUUID,pgUUID);