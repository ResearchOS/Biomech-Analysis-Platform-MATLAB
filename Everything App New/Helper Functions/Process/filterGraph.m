function [G] = filterGraph(src, vwUUID)

%% PURPOSE: FILTER THE GRAPH OF THE CURRENT ANALYSIS FOR THE CURRENT VIEW. ASSUME IT'S ALREADY UP TO DATE.

global conn globalG viewG;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

sqlquery = ['SELECT * FROM Views_Instances WHERE UUID = ''' vwUUID ''';'];
t = fetch(conn, sqlquery);
t = table2MyStruct(t);

inclNodes = t.InclNodes;
name = t.Name;

if isempty(inclNodes)
    inclNodes = {};    
end

if isempty(name)
    name = {};
end

% if isempty(viewG.Edges)
%     EndNodes = cell(0,2);
%     Name = cell(0,1);
%     OutOfDate = [];
%     nodeTable = table(Name, OutOfDate);
%     edgeTable = table(EndNodes,Name);
%     G = digraph(edgeTable, nodeTable);
%     viewG = G;
%     return;
% end

fcnsG = getFcnsOnlyDigraph(globalG);

names = fcnsG.Nodes.Name;
if isequal(name,'ALL')
    inclNodes = names; % Keep all nodes.
end
markerSize = getappdata(fig,'markerSize');
if isempty(markerSize)
    markerSize = repmat(4,length(names),1);
end
maxMarkerSize = max(markerSize);
minMarkerSize = min(markerSize);
if maxMarkerSize == minMarkerSize
    selIdx = false(size(names));
else
    selIdx = ismember(markerSize,maxMarkerSize);
end
selNames = names(selIdx);


exclNodesIdx = ~ismember(names,inclNodes);
viewG = rmnode(fcnsG,names(exclNodesIdx));
newSelNamesIdx = ismember(viewG.Nodes.Name,selNames);

markerSize = repmat(minMarkerSize,length(newSelNamesIdx),1); % Change markerSize length in case nodes are excluded.

% Assumes there's only two marker sizes.
markerSize(newSelNamesIdx) = maxMarkerSize;

setappdata(fig,'markerSize',markerSize);

G = viewG;