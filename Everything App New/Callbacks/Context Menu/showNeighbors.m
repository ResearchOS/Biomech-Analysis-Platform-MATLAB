function [] = showNeighbors(src, event)

%% PURPOSE: RENDER A POPUP FIGURE OF THE GRAPH WITH JUST THE SELECTED NODE, AND ITS NEIGHBORS.

global globalG popupG;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

uuid=selNode.NodeData.UUID;

G = globalG;

succs = successors(G,uuid);
preds = predecessors(G,uuid);

edgeTableIdx = (ismember(G.Edges.EndNodes(:,1),preds) & ismember(G.Edges.EndNodes(:,2),uuid)) | ...
    (ismember(G.Edges.EndNodes(:,1),uuid) & ismember(G.Edges.EndNodes(:,2),succs));

edgeTable = G.Edges.EndNodes(edgeTableIdx,:);

H = digraph(edgeTable(:,1),edgeTable(:,2));
% H.Edges.Name = G.Edges.Name(edgeTableIdx);
% H.Edges.PrettyName = G.Edges.PrettyName(edgeTableIdx);
markerSize = repmat(4,length(H.Nodes.Name),1);
nodeIdx = ismember(H.Nodes.Name, uuid);
% H.Nodes.PrettyName = getName(H.Nodes.Name);
% H.Nodes.PrettyName = G.Nodes.PrettyName(ismember(G.Nodes.Name, H.Nodes.Name));
markerSize(nodeIdx) = 8;
Q = uifigure('Units','normalized');
delete(Q.Children);
ax = uiaxes(Q,'Box','off','XTickLabel',{},'YTickLabel',{},'XTick',{},'YTick',{},'HandleVisibility','on','Position',[10, 10, 500, 350]);
set(ax,'PickableParts','visible','HitTest','on','ButtonDownFcn',@(figAx, event) digraphAxesButtonDownFcn(figAx));
ax.UserData.G = H;

Qhandles.Axes = ax;
Qhandles.PrettyVarsCheckbox = uicheckbox(Q,'Value',1,'Text','Pretty Vars','Position',[100 375 84 22]);
Qhandles.addNodesButton = uibutton(Q,'Text','N+','Position',[250 375 84 22],'ButtonPushedFcn',@(addNodesButton, event) addNodesButtonPushed(addNodesButton));
setappdata(Q,'handles',Qhandles);
setappdata(Q,'markerSize',markerSize);
renderGraph(fig, H, markerSize, [], [], ax);
popupG = H;