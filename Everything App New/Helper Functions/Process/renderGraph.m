function [] = renderGraph(src, G, markerSize, color, edgeID)

%% PURPOSE: RENDER THE DIGRAPH IN THE UI AXES

global conn;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if nargin==1 || isempty(G)
    G = getappdata(fig,'viewG');
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
    % All nodes
    color = repmat(defaultColor,length(markerSize),1); % Default blue color
end

% The nodes that haven't had all of their variables filled in.
unfinishedIdx = getUnfinishedFcns(G); % FIX THIS AFTER RE-IMPLEMENTING NAMES IN CODE
color(unfinishedIdx,:) = repmat(rgb('bright orange'),sum(unfinishedIdx),1);
markerSize(unfinishedIdx,:) = repmat(6,sum(unfinishedIdx),1);

% The selected node.
if any(markerSize==8)
    color(markerSize==8,:) = repmat([0 0 0],sum(markerSize==8),1); % Black
end

% Reset the axes.
ax = handles.Process.digraphAxes;
delete(ax.Children);
set(ax,'ColorOrderIndex', 1);

if isempty(G.Edges)
    return;
end

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
if any(markerSize==8)
    idxNums = find(ismember(markerSize, 8));
    for i=1:length(idxNums)
        ins = inedges(G, G.Nodes.Name(idxNums(i)));
        highlight(h, 'Edges',ins, 'EdgeColor',rgb('grass green'),'LineWidth',2);
        labeledge(h, ins, edgenames(ins));
        outs = outedges(G, G.Nodes.Name(idxNums(i)));
        highlight(h, 'Edges', outs, 'EdgeColor',rgb('brick red'),'LineWidth',2);
        labeledge(h, outs, edgenames(outs));
    end
end

%% Change line style to '--' for edges (variables) that are outdated.
sqlquery = ['SELECT UUID, OutOfDate FROM Variables_Instances'];
t = fetch(conn, sqlquery);
t = table2MyStruct(t);
outOfDateIdx = t.OutOfDate==1;
notDoneIdx = find(ismember(G.Edges.Name,t.UUID(outOfDateIdx)));
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

setappdata(fig,'viewG',G);
setappdata(fig,'markerSize',markerSize);

drawnow;