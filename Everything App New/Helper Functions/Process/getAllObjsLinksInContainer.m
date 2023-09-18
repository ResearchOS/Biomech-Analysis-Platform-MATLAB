function [G2] = getAllObjsLinksInContainer(G, containerUUIDs)

%% PURPOSE: GIVEN THE GRAPH OF ALL OBJECTS (FROM getAllObjLinks) RETURN THE SUBSET THAT ARE WITHIN (HAVE A PATH TO) THE SPECIFIED CONTAINER.
% Can provide more than one container UUID (e.g. multiple analyses, or an
% analysis and project, etc.)

%% HOW TO MAKE SURE THAT ANOTHER OBJECT IS NOT INCLUDED THAT IS NOT IN THE CONTAINER?
% E.G. ANOTHER GROUP THAT IS NOT PART OF THE SPECIFIED CONTAINER, BUT THE
% TWO GROUPS SHARE A FUNCTION OR INPUT VARIABLE?

if ischar(containerUUIDs)
    containerUUIDs = {containerUUIDs};
end

%% Remove all of the successor nodes of the container(s), so that another route is not found to them.
succs = {};
for i=1:length(containerUUIDs)
    succs = [succs; successors(G,containerUUIDs{i})];
end
succs = unique(succs,'stable');
G = rmnode(G,succs);

containerNodesIdx = ismember(G.Nodes.Name,containerUUIDs);

%% 1. Reverse the graph to find all nodes that have a path to the container.
% The output of this step is used for Step 2, but then discarded.
Hback = transclosure(flipedge(G));
Rback = full(adjacency(Hback));
for i=1:size(Rback,1)
    Rback(i,i) = 1; % Make nodes on diagonal 1, so that the container nodes are also returned.
end

reachableNodesIdxBack = any(logical(Rback(containerNodesIdx,:)),1); % All of the nodes reachable from the container node(s).

%% 2. Use the forward graph to find all nodes within the container that are reachable from the reachable nodes, 
% but don't have a path to the container themselves.
Hfwd = transclosure(G);
Rfwd = full(adjacency(Hfwd));
for i= 1:size(Rfwd,1)
    Rfwd(i,i) = 1;
end

reachableNodesIdxFwd = any(logical(Rfwd(reachableNodesIdxBack,:)),1); % Includes some nodes that were already found.

reachableNodesFwd = G.Nodes.Name(reachableNodesIdxFwd);

%% 3. Ensure that no paths are taken that route around the container node (e.g. another group connects to the analysis)
% Get the nodes that can be reached, and are within the current container
% (have an edge to the current container in the transitive closure graph)
inContainerIdx = ismember(Hfwd.Edges.EndNodes(:,2),containerUUIDs) & ismember(Hfwd.Edges.EndNodes(:,1),reachableNodesFwd);

%% This is the comprehensive list of nodes with a path to the container.
inContainerNodes = Hfwd.Edges.EndNodes(inContainerIdx,1);

%% Experimental:
% To avoid an issue with PR's being shared in an unwanted way among PG's due to shared output VR's, 
% check that the PR has at least one successor also in the container. If not, remove
% the PR.
% Also removes PG's for the same reason, as PR's could feed into PG's in
% unexpected ways.
[containerType] = deText(containerUUIDs);
if any(contains(containerType,'PG'))
    prpgIdx = contains(inContainerNodes,{'PR','PG'});
    prpgNames = inContainerNodes(prpgIdx);
    for i=1:length(prpgNames)
        succs = successors(G, prpgNames{i});
        if any(ismember(succs,containerUUIDs))
            continue;
        end
        inContainerNodes(ismember(inContainerNodes,prpgNames{i})) = [];
    end
end

%% Modify the digraph to only contain nodes in this container.
remNodeIDs = G.Nodes.Name(~ismember(G.Nodes.Name,inContainerNodes));
G2 = rmnode(G, remNodeIDs); % Return the digraph with a subset of objects.