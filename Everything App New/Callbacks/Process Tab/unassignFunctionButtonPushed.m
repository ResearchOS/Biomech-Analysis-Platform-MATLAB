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

type = deText(selUUID);

if ~isequal(type,'PR')
    disp('Must have a process selected to use this button!');
    return;
end

[~,list] = getUITreeFromNode(selNode);
if length(list)>2
    container = list(2); % If indented.
    containerUUID = container.NodeData.UUID;
else
    containerUUID = getContainer(tab);
end

%% Unlink the PR from the current group or analysis.
unlinkObjs(selUUID, containerUUID);

%% Update GUI
proceed = deleteNode(selNode);
if ~proceed
    return;
end

%% Set outOfDate
setObjsOutOfDate(fig, selUUID, true, true);