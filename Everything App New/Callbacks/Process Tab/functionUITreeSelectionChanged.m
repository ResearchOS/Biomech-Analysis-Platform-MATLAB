function []=functionUITreeSelectionChanged(src,event)

%% PURPOSE:

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode = handles.Process.functionUITree.SelectedNodes;

if isempty(selNode)
    uuid = '';
else
    uuid = selNode.NodeData.UUID;
end

renderGraph(fig, [], [], [], [], [], uuid);