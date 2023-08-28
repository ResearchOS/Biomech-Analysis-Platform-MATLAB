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
if ~isequal(class(obj),'matlab.ui.control.UIAxes') && doButtonDownFcn
    digraphAxesButtonDownFcn(src, uuid);
end

%% Select the corresponding node in the analysis UI tree
node = selectNode(handles.Process.analysisUITree, uuid);
if ~isequal(node.Parent,handles.Process.analysisUITree)
    handles.Process.analysisUITree.SelectedNodes = node.Parent;
    drawnow;
end