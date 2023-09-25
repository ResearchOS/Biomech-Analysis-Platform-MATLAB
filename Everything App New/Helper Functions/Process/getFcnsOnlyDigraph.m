function [G2] = getFcnsOnlyDigraph(G, types)

%% PURPOSE: REMOVE ALL NODES THAT ARE NOT VR OR PR. CONNECTS PR TO PR, NAMES THE EDGES BY THE VR UUID
% USES THE OUTPUT OF getSubgraph
% USED AS THE INPUT TO TOPOLOGICAL SORTING (toposort)


%% 1. Remove all nodes that are not PR or VR.
if nargin==1
    types = {'VR','PR'};
end

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

    succs(contains(succs,'AN')) = [];
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

%% Append the non-PR and VR objects to Name and EndNodes.
nonVRedgeIdx = ~(contains(G.Edges.EndNodes(:,1),'VR') | contains(G.Edges.EndNodes(:,2),'VR'));
EndNodes = [EndNodes; G.Edges.EndNodes(nonVRedgeIdx,:)];
Name = [Name; repmat({''},sum(nonVRedgeIdx),1)];

%% Make a new digraph from the edges and nodes.
edgeTable = table(EndNodes, Name);
nonVRIdx = contains(G.Nodes.Name,types(~ismember(types,'VR')));
Name = G.Nodes.Name(nonVRIdx);
nodeTable = table(Name);
G2 = digraph(edgeTable,nodeTable);