function [reachableNodes] = getReachableNodes(G, uuid)

%% PURPOSE: GET ALL OF THE REACHABLE NODES FROM THE SPECIFIED UUID IN THE SPECIFIED GRAPH

H = transclosure(G);
R = full(adjacency(H));
for i=1:size(R,1)
    R(i,i)=1;
end

uuidIdx = ismember(G.Nodes.Name,uuid);
reachableIdx = any(logical(R(uuidIdx,:)),1);
reachableNodes = G.Nodes.Name(reachableIdx);