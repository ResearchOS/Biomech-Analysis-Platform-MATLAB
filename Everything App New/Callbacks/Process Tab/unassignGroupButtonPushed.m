function []=unassignGroupButtonPushed(src,event)

%% PURPOSE: UNASSIGN PROCESSING GROUP FROM THE CURRENT ANALYSIS OR GROUP (DEPENDING ON WHICH TAB I'M ON)

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

currTab = handles.Process.currentSubtab.SelectedTab.Title;
switch currTab
    case 'Analysis'
        uiTree = handles.Process.analysisUITree;
    case 'Group'
        uiTree = handles.Process.groupUITree;
end

selNode=uiTree.SelectedNodes;

if isempty(selNode)
    return;
end

selUUID = selNode.NodeData.UUID;

[containerUUID] = getContainer(selUUID, fig);
type = deText(selUUID);

if ~isequal(type,'PG')
    disp('Must have a process group selected to use this button!');
    return;
end

%% Update GUI
proceed = deleteNode(selNode);
if ~proceed
    return;
end

%% Remove the group from the current group or analysis.
contStruct = loadJSON(containerUUID);
idx = ismember(contStruct.RunList,selUUID);
contStruct.RunList(idx) = [];

writeJSON(getJSONPath(contStruct), contStruct);

%% Unlink the group from the current group or analysis.
unlinkObjs(selUUID, contStruct);