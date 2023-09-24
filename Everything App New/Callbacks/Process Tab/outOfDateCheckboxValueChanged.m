function []=outOfDateCheckboxValueChanged(src,event)

%% PURPOSE: SET THE OUT OF DATE VALUE FOR THE CURRENTLY SELECTED FUNCTION IN THE GROUP UI TREE

global conn;

disp('Setting out of date  attribute');

fig = ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles'); 

selNode = handles.Process.groupUITree.SelectedNodes;

if isempty(selNode)
    return;
end

outOfDateBool = handles.Process.outOfDateCheckbox.Value;

uuid = selNode.NodeData.UUID;

setObjsOutOfDate(fig, uuid, outOfDateBool, true);

toggleDigraphCheckboxValueChanged(fig);

disp('Finished setting out of date attribute');