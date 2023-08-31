function []=unassignFunctionButtonPushed(src,event)

%% PURPOSE: UNASSIGN PROCESSING FUNCTION FROM PROCESSING GROUP

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

[containerUUID] = getContainer(selUUID, fig);
type = deText(selUUID);

if ~isequal(type,'PR')
    disp('Must have a process selected to use this button!');
    return;
end

%% Unlink the group from the current group or analysis.
unlinkObjs(selUUID, containerUUID);

%% Update GUI
proceed = deleteNode(selNode);
if ~proceed
    return;
end