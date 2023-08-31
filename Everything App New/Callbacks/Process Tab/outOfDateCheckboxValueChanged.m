function []=outOfDateCheckboxValueChanged(src,event)

%% PURPOSE: SET THE OUT OF DATE VALUE FOR THE CURRENTLY SELECTED FUNCTION IN THE GROUP UI TREE

global conn;

fig = ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles'); 

selNode = handles.Process.groupUITree.SelectedNodes;

if isempty(selNode)
    return;
end

outOfDateBool = handles.Process.outOfDateCheckbox.Value;

uuid = selNode.NodeData.UUID;

setPR_VROutOfDate(fig, uuid, outOfDateBool,'Manual');

toggleDigraphCheckboxValueChanged(fig);