function [] = addNodesButtonPushed(src, event)

%% PURPOSE: ADD ADDITIONAL NODES TO THE NEIGHBORS GRAPH.

global globalG popupG;

fig = ancestor(src,'figure','toplevel');
handles = getappdata(fig,'handles');

ax = handles.Axes;
markerSize = getappdata(fig,'markerSize');
uuid = popupG.Nodes.Name(markerSize==8);

if isempty(uuid)
    return;
end

nodes = {};
if indegree(popupG, uuid)==0
    nodes = predecessors(globalG, uuid);
elseif outdegree(popupG, uuid)==0
    nodes = successors(globalG, uuid);
end

popupG = subgraph(globalG, [popupG.Nodes.Name; nodes]);
idx = ismember(popupG.Nodes.Name, uuid);
markerSize = repmat(4,length(idx),1);
markerSize(idx) = 8;
setappdata(fig,'markerSize',markerSize);

assert(length(popupG.Nodes.Name)==length(markerSize));

renderGraph(fig, popupG, markerSize, [], [], ax);