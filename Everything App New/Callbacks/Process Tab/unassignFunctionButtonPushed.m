function []=unassignFunctionButtonPushed(src,event)

%% PURPOSE: UNASSIGN PROCESSING FUNCTION FROM PROCESSING GROUP

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

[containerUUID, uiTree] = getContainer(fig);

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