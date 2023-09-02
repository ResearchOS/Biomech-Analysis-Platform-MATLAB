function [] = removeNodesFromView(src, nodes)

%% PURPOSE: REMOVE NODES FROM THE CURRENT VIEW.

global conn;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if ~iscell(nodes)
    nodes = {nodes};
end

G = getappdata(fig, 'viewG');

G = rmnode(G, nodes);

inclNodes = G.Nodes.Name;

% Set the new list
inclNodesJSON = jsonencode(inclNodes);
Current_View = getCurrent('Current_View');
sqlquery = ['UPDATE Views_Instances SET InclNodes = ''' inclNodesJSON ''' WHERE UUID = ''' Current_View ''';'];
execute(conn, sqlquery);

markerSize = repmat(4,length(G.Nodes.Name),1);

setappdata(fig,'viewG',G);
setappdata(fig,'markerSize',markerSize);