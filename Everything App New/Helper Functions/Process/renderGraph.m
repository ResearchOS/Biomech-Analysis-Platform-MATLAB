function [] = renderGraph(src, G, nodeMatrix, edges, markerSize, color)

%% PURPOSE: RENDER THE DIGRAPH IN THE UI AXES

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if nargin==1 || isempty(G)
    G = getappdata(fig,'digraph');
    nodeMatrix = getappdata(fig,'nodeMatrix');
    edges = getappdata(fig,'edges');
end
if exist('markerSize','var')~=1
    markerSize = getappdata(fig,'markerSize');
    if isempty(markerSize)
        markerSize = 4;
    end
end
defaultColor = [0 0.447 0.741];
if ~exist('color','var')
    color = getappdata(fig,'color');
    if isempty(color)
        color = defaultColor; % Default blue color
    end
end

% Reset the axes.
ax = handles.Process.digraphAxes;
delete(ax.Children);
set(ax,'ColorOrderIndex', 1);

h  = plot(ax,G,'NodeLabel',G.Nodes.PrettyName,'Interpreter','none','PickableParts','none','HitTest','on');

h.MarkerSize = markerSize;

h.NodeColor = color;
h.EdgeColor = defaultColor;

% labeledge(G, nodeMatrix(:,1), nodeMatrix(:,2), edges);

setappdata(fig,'digraph',G);
setappdata(fig,'nodeMatrix',nodeMatrix);
setappdata(fig,'edges',edges);
setappdata(fig,'markerSize',markerSize);
setappdata(fig,'color',color);