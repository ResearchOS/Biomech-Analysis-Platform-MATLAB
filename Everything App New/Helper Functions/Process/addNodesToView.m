function []=addNodesToView(src,nodes)

%% PURPOSE: ADD NODES TO A VIEW

global conn viewG globalG;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if ~iscell(nodes)
    nodes = {nodes};
end

% Add the edges from the main digraph to the current view.
allG = getFcnsOnlyDigraph(globalG);

% Add the nodes that are not yet already part of the graph.
G = viewG;
uuids = nodes(~ismember(nodes,G.Nodes.Name));
uuidIdx = ismember(allG.Nodes.Name,uuids);
addNodesTable = allG.Nodes(uuidIdx,:);
G = addnode(G, addNodesTable);

addEdgesIdx = false(size(allG.Edges.EndNodes,1),1);
for i=1:length(uuids)
    uuid = uuids{i};       
    addEdgesIdx = addEdgesIdx | (ismember(allG.Edges.EndNodes(:,1),G.Nodes.Name) & ismember(allG.Edges.EndNodes(:,2),uuid)) | ... % inedges to the new node.
        (ismember(allG.Edges.EndNodes(:,1),uuid) & ismember(allG.Edges.EndNodes(:,2),G.Nodes.Name)); % outedges of the new node.        
end
addEdgesTable = allG.Edges(addEdgesIdx,:);
G = addedge(G, addEdgesTable);

inclNodes = G.Nodes.Name;

inclNodesJSON = jsonencode(inclNodes);
Current_View = getCurrent('Current_View');
sqlquery = ['UPDATE Views_Instances SET InclNodes = ''' inclNodesJSON ''' WHERE UUID = ''' Current_View ''';'];
execute(conn, sqlquery);

% Get the markers that were originally selected.
markerSize = getappdata(fig,'markerSize');
selNodesIdx = markerSize==8;
selNodes = viewG.Nodes.Name(selNodesIdx);

% Make sure those same markers stay selected, and also update the
% markerSize variable.
selNodesIdxNew = ismember(G.Nodes.Name,selNodes);
markerSize = repmat(4,length(G.Nodes.Name),1);
markerSize(selNodesIdxNew) = 8;
setappdata(fig,'markerSize',markerSize);

viewG = G;