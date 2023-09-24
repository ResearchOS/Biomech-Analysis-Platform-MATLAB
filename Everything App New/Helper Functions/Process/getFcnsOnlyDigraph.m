function [G2] = getFcnsOnlyDigraph(G)

%% PURPOSE: REMOVE ALL NODES THAT ARE NOT VR OR PR. CONNECTS PR TO PR, NAMES THE EDGES BY THE VR UUID
% USES THE OUTPUT OF getSubgraph
% USED AS THE INPUT TO TOPOLOGICAL SORTING (toposort)


%% 1. Remove all nodes that are not PR or VR.
types = {'VR','PR'};

remIdx = ~contains(G.Nodes.Name,types);
remNodes = G.Nodes.Name(remIdx);

G = rmnode(G, remNodes);

%% 2. Remove all VR nodes, replace them with edges between PR's.

vrIdx = contains(G.Nodes.Name,{'VR'});
vrNodes = G.Nodes.Name(vrIdx);

Name = {};
EndNodes = cell(0,2);
for nodeIdx=1:length(vrNodes)
    uuid = vrNodes{nodeIdx};
    % Get each VR's predecessor & successor nodes.
    succs = successors(G, uuid);
    preds = predecessors(G, uuid);

    noPreds = false;
    noSuccs = false;

    if isempty(preds)
        noPreds = true;
        preds = {''};
    end

    if isempty(succs)
        noSuccs = true;
        succs = {''};
    end

    % Put them into an edge table so each predecessor and successor are directly
    % linked.    
    for predNum = 1:length(preds)
        for succNum = 1:length(succs)            
            if ~noPreds && ~noSuccs
                EndNodes(end+1,1:2) = [preds(predNum), succs(succNum)];
            end
        end
    end

    if ~noPreds && ~noSuccs
        Name = [Name; repmat({uuid},predNum*succNum,1)];
    end

end

%% Add the new edges, and remove the VR nodes (and associated edges) from the graph.
edgeTable = table(EndNodes, Name);
prIdx = contains(G.Nodes.Name,{'PR'});
Name = G.Nodes.Name(prIdx);
nodeTable = table(Name);
G2 = digraph(edgeTable,nodeTable);