function []=pasteText(src,event)

%% PURPOSE: PASTE A NODE'S COPIED TEXT INTO ANOTHER NODE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

if isempty(selNode)
    return;
end

uiTree = getUITreeFromNode(selNode);

copiedUUID = clipboard('paste');

if ~isUUID(copiedUUID)
    return;
end

[type] = deText(copiedUUID);

if isequal(uiTree, handles.Process.functionUITree) && isequal(type,'VR')
    assignVariableButtonPushed(fig,copiedUUID);
end