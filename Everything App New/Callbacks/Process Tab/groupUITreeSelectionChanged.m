function []=groupUITreeSelectionChanged(src, doButtonDownFcn)

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

%% Update the out of date checkbox.
struct = loadJSON(uuid);
handles.Process.outOfDateCheckbox.Value = struct.OutOfDate;

%% Update which specifyTrials are checked.
st = getST(uuid);
checkSpecifyTrialsUITree(st, handles.Process.allSpecifyTrialsUITree);

fillCurrentFunctionUITree(fig);

%% Select the corresponding processing node in the graph.
obj=get(fig,'CurrentObject');
if nargin==1
    doButtonDownFcn = true;
end
if ~isequal(class(obj),'matlab.ui.control.UIAxes') && doButtonDownFcn
    digraphAxesButtonDownFcn(src, uuid);
end