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

[type] = deText(copiedUUID);

if isequal(uiTree, handles.Process.functionUITree) && isequal(className2Abbrev(type, true), 'Variable')
    assignVariableButtonPushed(fig,copiedUUID);
end