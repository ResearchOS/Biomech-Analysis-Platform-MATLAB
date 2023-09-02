function [G] = filterGraph(src, vwUUID)

%% PURPOSE: FILTER THE GRAPH OF THE CURRENT ANALYSIS FOR THE CURRENT VIEW. ASSUME IT'S ALREADY UP TO DATE.

global conn;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

sqlquery = ['SELECT * FROM Views_Instances WHERE UUID = ''' vwUUID ''';'];
t = fetch(conn, sqlquery);
t = table2MyStruct(t);

inclNodes = t.InclNodes;

G = getappdata(fig,'digraph');
names = G.Nodes.Name;
markerSize = getappdata(fig,'markerSize');
maxMarkerSize = max(markerSize);
minMarkerSize = min(markerSize);
if maxMarkerSize == minMarkerSize
    selIdx = false(size(names));
else
    selIdx = ismember(markerSize,maxMarkerSize);
end
selNames = names(selIdx);

exclNodesIdx = ~ismember(names,inclNodes);

G = rmnode(G,names(exclNodesIdx));
newSelNamesIdx = ismember(G.Nodes.Name,selNames);

markerSize = repmat(minMarkerSize,length(newSelNamesIdx),1);

% Assumes there's only two marker sizes.
markerSize(newSelNamesIdx) = maxMarkerSize;
% markerSize(~newSelNamesIdx) = minMarkerSize;

setappdata(fig,'markerSize',markerSize);
setappdata(fig,'viewG',G);