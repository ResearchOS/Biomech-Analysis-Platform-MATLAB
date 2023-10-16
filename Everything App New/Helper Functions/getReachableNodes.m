function [reachableNodes] = getReachableNodes(G, uuids, dir)

%% PURPOSE: GET ALL OF THE REACHABLE NODES FROM THE SPECIFIED UUID IN THE SPECIFIED GRAPH. INCLUDES THE UUID INPUTTED!

if nargin<3
    dir = 'down';
end

if isequal(dir,'up')
    G = flipedge(G);
end
H = transclosure(G);
R = full(adjacency(H));
for i=1:size(R,1)
    R(i,i)=1;
end

uuidIdx = ismember(G.Nodes.Name,uuids);
reachableIdx = any(logical(R(uuidIdx,:)),1);
reachableNodes = G.Nodes.Name(reachableIdx);

if size(reachableNodes,2)>1
    reachableNodes = reachableNodes';
end