function [] = analysisUITreeSelectionChanged(src)

%% PURPOSE: UPDATE THE GROUP OR FUNCTION TAB (DEPENDING ON NODE TYPE) WITH THE CURRENT SELECTION IN THE ANALYSIS TAB.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Process.analysisUITree.SelectedNodes;

if isempty(selNode)
    return;
end

uuid = selNode.NodeData.UUID; % The selected group or function.
struct = loadJSON(uuid);

delete(handles.Process.groupUITree.Children);

[type, abstractID, instanceID] = deText(struct.UUID);

if isequal(type,'PR')
    node = uitreenode(handles.Process.groupUITree,'Text', struct.Text);
    node.NodeData.UUID = struct.UUID;
    selectNode(handles.Process.groupUITree, node.NodeData.UUID);
    return;
end

fillProcessGroupUITree(fig);