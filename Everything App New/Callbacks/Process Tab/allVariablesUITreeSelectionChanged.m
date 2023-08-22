function []=allVariablesUITreeSelectionChanged(src,event)

%% PURPOSE: 

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if ~handles.Process.toggleDigraphCheckbox.Value
    return;
end

selNode = handles.Process.allVariablesUITree.SelectedNodes;

if isempty(selNode)
    return;
end

uuid = selNode.NodeData.UUID;

renderGraph(src, [], [], [], uuid)