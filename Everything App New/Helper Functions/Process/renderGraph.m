function [] = renderGraph(src, G, markerSize, color, edgeID)

%% PURPOSE: RENDER THE DIGRAPH IN THE UI AXES

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if nargin==1 || isempty(G)
    G = getappdata(fig,'digraph');
end
if exist('markerSize','var')~=1 || isempty(markerSize)
    markerSize = getappdata(fig,'markerSize');
    if isempty(markerSize)
        markerSize = 4;
    end
end
% If a new node is being added as a result of adding a variable.
if length(markerSize)<length(G.Nodes.Name)
    markerSize = [markerSize; repmat(4,length(G.Nodes.Name)-length(markerSize),1)];
end
if length(markerSize)>length(G.Nodes.Name)
    markerSize(length(G.Nodes.Name)+1:end) = [];
end
defaultColor = [0 0.447 0.741];
if ~exist('color','var') || isempty(color)
    color = repmat(defaultColor,length(markerSize),1); % Default blue color
    if any(markerSize~=4)
        color(markerSize~=4,:) = [0 0 0];
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
h.LineWidth = 0.5;

if handles.Process.prettyVarsCheckbox.Value
    edgenames = G.Edges.PrettyName;
else
    edgenames = G.Edges.Name;
end

% If a node is selected, highlight its in and out edges.
if any(diff(markerSize)~=0)
    idx = ismember(markerSize, 8);
    ins = inedges(G, G.Nodes.Name(idx));
    highlight(h, 'Edges',ins, 'EdgeColor',rgb('grass green'),'LineWidth',2);
    labeledge(h, ins, edgenames(ins));
    outs = outedges(G, G.Nodes.Name(idx));
    highlight(h, 'Edges', outs, 'EdgeColor',rgb('brick red'),'LineWidth',2);
    labeledge(h, outs, edgenames(outs));
end

% Get the indices of which variables are outdated.
notDoneIdx = [];
for i=1:length(G.Edges.Name)
    varStruct = loadJSON(G.Edges.Name{i});
    if varStruct.OutOfDate
        notDoneIdx = [notDoneIdx; i];
    end
end
highlight(h, 'Edges', notDoneIdx, 'LineStyle','--');

% If an edge is selected (as in, a variable selected in the all variables list).
if exist('edgeID','var') && ~isempty(edgeID)
    [type, abstractID, instanceID] = deText(edgeID);
    if ~isempty(instanceID) && ischar(edgeID)
        edgeID = {edgeID}; % Instance selected
    elseif isempty(instanceID)
        edgeID = getInstances(edgeID);
    end
    
    edgeIdx = ismember(G.Edges.Name, edgeID);
    highlight(h, 'Edges', edgeIdx, 'EdgeColor', rgb('orange'),'LineWidth',2);
    labeledge(h, edgeIdx, edgenames(edgeIdx));
end

% If I want the data all plotted in a line, do that.
if isequal('Linear',handles.Process.switchDigraphModeDropDown.Value)
    order = orderDeps(G);
    x = zeros(length(order),1);
    y = NaN(length(order),1);
    for i=1:length(G.Nodes.Name)
        idx = find(ismember(order,G.Nodes.Name(i)));
        y(i) = -1*idx;
    end
    h.XData = x;
    h.YData = y;
end

setappdata(fig,'digraph',G);
setappdata(fig,'markerSize',markerSize);