function []=addNodesToView(src,nodes)

%% PURPOSE: ADD NODES TO A VIEW

global conn viewG globalG;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if ~iscell(nodes)
    nodes = {nodes};
end

% Add the node.
G = viewG;

% Add the edges from the main digraph to the current view.
allG = getFcnsOnlyDigraph(globalG);
% allG = globalG;

for i=1:length(nodes)
    uuid = nodes{i};
    nodeIdx = ismember(allG.Nodes.Name,uuid);
    addNode = allG.Nodes(nodeIdx,:);
    addEdgesIdx = (ismember(allG.Edges.EndNodes(:,1),G.Nodes.Name) & ismember(allG.Edges.EndNodes(:,2),uuid)) | ... % inedges to the new node.
        (ismember(allG.Edges.EndNodes(:,1),uuid) & ismember(allG.Edges.EndNodes(:,2),G.Nodes.Name)); % outedges of the new node.
    addEdges = allG.Edges(addEdgesIdx,:);
    if ~ismember(uuid,G.Nodes.Name)
        G = addnode(G, addNode);
        G = addedge(G, addEdges);
    end
end

inclNodes = G.Nodes.Name;

inclNodesJSON = jsonencode(inclNodes);
Current_View = getCurrent('Current_View');
sqlquery = ['UPDATE Views_Instances SET InclNodes = ''' inclNodesJSON ''' WHERE UUID = ''' Current_View ''';'];
execute(conn, sqlquery);

viewG = G;