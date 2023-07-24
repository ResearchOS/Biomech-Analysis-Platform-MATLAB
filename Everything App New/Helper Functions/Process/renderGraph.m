function [] = renderGraph(src, G, nodeMatrix, edges)

%% PURPOSE: RENDER THE DIGRAPH IN THE UI AXES.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% Reset the axes.
ax = handles.Process.digraphAxes;
delete(ax.Children);
set(ax,'ColorOrderIndex', 1);

h  = plot(ax,G,'NodeLabel',G.Nodes.Name,'Interpreter','none');

h.MarkerSize = 4;


defaultColor = [0 0.447 0.741]; % Default blue color

h.NodeColor = defaultColor;
h.EdgeColor = defaultColor;

labeledge(G, nodeMatrix(:,1), nodeMatrix(:,2), edges);