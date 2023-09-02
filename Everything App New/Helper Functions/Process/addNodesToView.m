function []=addNodesToView(src,nodes)

%% PURPOSE: ADD NODES TO A VIEW

global conn;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if ~iscell(nodes)
    nodes = {nodes};
end

% Add the node.
G = getappdata(fig,'viewG');

% Add the edges from the main digraph to the current view.
allG = getappdata(fig,'digraph');

for i=1:length(nodes)
    uuid = nodes{i};
    nodeIdx = ismember(allG.Nodes.Name,uuid);
    addNode = allG.Nodes(nodeIdx,:);
    addEdgesIdx = (ismember(allG.Edges.EndNodes(:,1),G.Nodes.Name) & ismember(allG.Edges.EndNodes(:,2),uuid)) | ... % inedges to the new node.
        (ismember(allG.Edges.EndNodes(:,1),uuid) & ismember(allG.Edges.EndNodes(:,2),G.Nodes.Name)); % outedges of the new node.
    addEdges = allG.Edges(addEdgesIdx,:);
    G = addnode(G, addNode);
    G = addedge(G, addEdges);
end

inclNodes = G.Nodes.Name;

inclNodesJSON = jsonencode(inclNodes);
Current_View = getCurrent('Current_View');
sqlquery = ['UPDATE Views_Instances SET InclNodes = ''' inclNodesJSON ''' WHERE UUID = ''' Current_View ''';'];
execute(conn, sqlquery);

setappdata(fig,'viewG',G);