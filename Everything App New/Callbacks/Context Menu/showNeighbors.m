function [] = showNeighbors(src, event)

%% PURPOSE: RENDER A POPUP FIGURE OF THE GRAPH WITH JUST THE SELECTED NODE, AND ITS NEIGHBORS.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

uuid=selNode.NodeData.UUID;

G = getappdata(fig,'digraph');
if isempty(G)
    G = refreshDigraph(fig);
end

succs = successors(G,uuid);
preds = predecessors(G,uuid);

edgeTableIdx = (ismember(G.Edges.EndNodes(:,1),preds) & ismember(G.Edges.EndNodes(:,2),uuid)) | ...
    (ismember(G.Edges.EndNodes(:,1),uuid) & ismember(G.Edges.EndNodes(:,2),succs));

edgeTable = G.Edges.EndNodes(edgeTableIdx,:);

H = digraph(edgeTable(:,1),edgeTable(:,2));
H.Edges.Name = G.Edges.Name(edgeTableIdx);
H.Edges.PrettyName = G.Edges.PrettyName(edgeTableIdx);
markerSize = repmat(4,length(H.Nodes.Name),1);
nodeIdx = ismember(H.Nodes.Name, uuid);
H.Nodes.PrettyName = G.Nodes.PrettyName(ismember(G.Nodes.Name, H.Nodes.Name));
markerSize(nodeIdx) = 8;
Q = uifigure('Units','normalized');
delete(Q.Children);
ax = uiaxes(Q,'Box','off','XTickLabel',{},'YTickLabel',{},'XTick',{},'YTick',{});
set(ax,'PickableParts','visible','HitTest','on','ButtonDownFcn',@(figAx, event) digraphAxesButtonDownFcn(figAx));
ax.UserData.G = H;

handles.PrettyVarsCheckbox = uicheckbox(Q,"Value",0,'Text','Pretty Vars');
setappdata(Q,'handles',handles);
renderGraph(fig, H, markerSize, [], [], ax);