function [] = renderDigraph(src, G)

%% PURPOSE: NEW, CLEANER VERSION OF RENDERGRAPH.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

n = length(G.Nodes.Name);
selIdx = G.Nodes.Selected;
outOfDateNodesIdx = G.Nodes.OutOfDate;
outOfDateEdgesIdx = G.Edges.OutOfDate;

markerSize = repmat(4,n,1);
defaultColor = [0 0.447 0.741];
color = repmat(defaultColor, n, 1);

markerSize(selIdx) = 8;
color(selIdx,:) = repmat([0 0 0],sum(selIdx),1);

nodeNames = G.Nodes.PrettyName;
if handles.Process.prettyVarsCheckbox.Value
    edgeNames = G.Edges.PrettyName;    
else
    edgeNames = G.Edges.Name;
    % nodeNames = G.Nodes.Name;
end

h = plot(handles.Process.digraphAxes, G, 'NodeLabel', nodeNames, 'Interpreter', 'none', 'PickableParts', 'none', 'HitTest', 'on');

h.MarkerSize = markerSize;
h.NodeColor = color;
h.EdgeColor = defaultColor;
h.LineWidth = 0.5;

%% Show input and outputs to the selected node(s).
if any(selIdx)
    idxNums = find(selIdx==1);
    ins = [];
    outs = [];
    for i=1:length(idxNums)
        ins = [ins; inedges(G, G.Nodes.Name(idxNums(i)))];
        outs = [outs; outedges(G, G.Nodes.Name(idxNums(i)))];
    end
    
    highlight(h, 'Edges',ins, 'EdgeColor',rgb('grass green'),'LineWidth',2);     
    highlight(h, 'Edges', outs, 'EdgeColor',rgb('brick red'),'LineWidth',2);
    labeledge(h, ins, edgeNames(ins));
    labeledge(h, outs, edgeNames(outs));
end

%% Show out of date variables.
if any(outOfDateEdgesIdx)
    outOfDateEdgesIdxNums = find(outOfDateEdgesIdx==1);
    highlight(h, 'Edges', outOfDateEdgesIdxNums, 'LineStyle', '--');
end

%% Show the currently selected variable in the current function UI tree
uuid = getSelUUID(handles.Process.functionUITree);
if isUUID(uuid)
    edgesIdx = find(ismember(G.Edges.Name, uuid));
    highlight(h, 'Edges', edgesIdx, 'EdgeColor', rgb('orange'), 'LineWidth', 2);
    labeledge(h, edgesIdx, edgeNames(edgesIdx));
end