function []=functionUITreeSelectionChanged(src,event)

%% PURPOSE:

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if ~handles.Process.toggleDigraphCheckbox.Value
    return; % Don't do anything if not showing the digraph.
end

selNode = handles.Process.functionUITree.SelectedNodes;

if isempty(selNode)
    uuid = '';
else
    if ~isstruct(selNode.NodeData)
        return;
    end
    uuid = selNode.NodeData.UUID;
end

% If no node in the graph is selected, select the current node.
markerSize = getappdata(fig,'markerSize');

if isscalar(markerSize) || ~any(markerSize==8)
    % 1. Get the name of the current function.
    fcnNode = handles.Process.groupUITree.SelectedNodes;
    if isempty(fcnNode)
        error('Wut');
    end
    fcnUUID = fcnNode.NodeData.UUID;

    % 2. Get its index in the digraph.
    G = getappdata(fig,'digraph');
    idx = ismember(G.Nodes.Name,fcnUUID);

    % 3. Set the marker size
    markerSize = repmat(4,length(G.Nodes.Name),1);
    markerSize(idx) = 8;

    setappdata(fig,'markerSize',markerSize);
end

renderGraph(fig, [], [], [], uuid);