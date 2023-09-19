function [G2] = getAllObjsLinksInContainer(G, containerUUIDs, dir)

%% PURPOSE: GIVEN THE GRAPH OF ALL OBJECTS (FROM getAllObjLinks) RETURN THE SUBSET THAT ARE WITHIN (HAVE A PATH TO) THE SPECIFIED CONTAINER.
% Can provide more than one container UUID (e.g. multiple analyses, or an
% analysis and project, etc.)
% NOTE: 'Container' is not the proper terminology. Inputs can be any
% object type, and are just the starting point.

%% HOW TO MAKE SURE THAT ANOTHER OBJECT IS NOT INCLUDED THAT IS NOT IN THE CONTAINER?
% E.G. ANOTHER GROUP THAT IS NOT PART OF THE SPECIFIED CONTAINER, BUT THE
% TWO GROUPS SHARE A FUNCTION OR INPUT VARIABLE?'

if nargin<3
    dir = 'up';
end

if ischar(containerUUIDs)
    containerUUIDs = {containerUUIDs};
end

%% Remove all of the successor nodes of the container(s), so that another route is not found to them.
% if ~isequal(dir,'both')
    % succs = {};
    % for i=1:length(containerUUIDs)
    %     succs = [succs; successors(G,containerUUIDs{i})];
    % end
    % succs = unique(succs,'stable');
    % G = rmnode(G,succs);

reachableNodesIdx = ismember(G.Nodes.Name,containerUUIDs);
% end

%% 1. Reverse the graph to find all nodes that have a path to the container.
% The output of this step is used for Step 2, but then discarded.
if ~isequal(dir,'down')
    H = transclosure(flipedge(G));
    R = full(adjacency(H));
    for i=1:size(R,1)
        R(i,i) = 1; % Make nodes on diagonal 1, so that the container nodes are also returned.
    end

    reachableNodesIdx = any(logical(R(reachableNodesIdx,:)),1); % All of the nodes reachable from the container node(s).
else
    reachableNodesIdx = ismember(G.Nodes.Name,containerUUIDs);
end

%% 2. Use the forward graph to find all nodes within the container that are reachable from the reachable nodes, 
% but may not have a path to the container themselves.
% For down and upstream
H = transclosure(G);
R = full(adjacency(H));
for i= 1:size(R,1)
    R(i,i) = 1;
end

reachableNodesIdx = any(logical(R(reachableNodesIdx,:)),1); % Includes some nodes that were already found.

reachableNodes = G.Nodes.Name(reachableNodesIdx);

%% 3. Ensure that no paths are taken that route around the container node (e.g. another group connects to the analysis)
% Get the nodes that can be reached, and are within the current container
% (have an edge to the current container in the transitive closure graph)
inContainerIdx = ismember(H.Edges.EndNodes(:,1),reachableNodes) & ismember(H.Edges.EndNodes(:,2),containerUUIDs);

%% This is the comprehensive list of nodes with a path to the container.
inContainerNodes = H.Edges.EndNodes(inContainerIdx,1);

%% Experimental:
% To avoid an issue with nodes being shared in an unwanted way among parent nodes due to overlapping paths, 
% check that the node has at least one successor also in the container. If not, remove the node.
delIdx = [];
for i=1:length(inContainerNodes)
    succs = successors(H, inContainerNodes{i}); % H
    if any(ismember(succs,containerUUIDs))
        continue; % If in the container, no problem, continue on.
    end
    delIdx = [delIdx; i];
end
inContainerNodes(delIdx) = [];

%% Modify the digraph to only contain nodes in this container.
remNodeIDs = G.Nodes.Name(~ismember(G.Nodes.Name,inContainerNodes));
G2 = rmnode(G, remNodeIDs); % Return the digraph with a subset of objects.