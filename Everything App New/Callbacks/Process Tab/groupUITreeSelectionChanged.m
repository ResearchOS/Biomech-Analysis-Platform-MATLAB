function []=groupUITreeSelectionChanged(src,event)

%% PURPOSE: SHOW THE CURRENT FUNCTION'S VARIABLES IN THE FUNCTIONS UI TREE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Process.groupUITree.SelectedNodes;

if isempty(selNode)
    return;
end

uuid = selNode.NodeData.UUID;

delete(handles.Process.functionUITree.Children);

abbrev = deText(uuid);
if isequal(abbrev,'PG')
    checkSpecifyTrialsUITree({}, handles.Process.allSpecifyTrialsUITree);
    return;
end

%% Update which specifyTrials are checked.
st = getST(uuid);
checkSpecifyTrialsUITree(st, handles.Process.allSpecifyTrialsUITree);

fillCurrentFunctionUITree(fig);