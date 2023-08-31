function []=unassignGroupButtonPushed(src,event)

%% PURPOSE: UNASSIGN PROCESSING GROUP FROM THE CURRENT ANALYSIS OR GROUP (DEPENDING ON WHICH TAB I'M ON)

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

tab = handles.Process.subtabCurrent.SelectedTab;
currTab = tab.Title;
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

[containerUUID] = getContainer(tab);
type = deText(selUUID);

if ~isequal(type,'PG')
    disp('Must have a process group selected to use this button!');
    return;
end

%% Unlink the group from the current group or analysis.
unlinkObjs(selUUID, containerUUID);

%% Update GUI
proceed = deleteNode(selNode);
if ~proceed
    return;
end