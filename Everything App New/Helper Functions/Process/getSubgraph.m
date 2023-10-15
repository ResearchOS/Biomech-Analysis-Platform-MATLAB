function [tmpG] = getSubgraph(G, uuids, dir)

%% PURPOSE: GIVEN THE GRAPH OF ALL OBJECTS (FROM getAllObjLinks) RETURN THE SUBGRAPH THAT HAS A PATH TO/FROM THE SPECIFIED NODE.
% Can provide more than one UUID

if nargin<3
    dir = 'up';
end

if ~ismember(dir,{'up','down'})
    nodes = uuids;
else
    nodes = getReachableNodes(G, uuids, dir);
end
tmpG = subgraph(G, nodes);