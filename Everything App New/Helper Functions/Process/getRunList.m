function [orderedPRList, listOrder] = getRunList(G, containerUUID)

%% PURPOSE: GET THE ORDER OF ITEMS IN THIS DIGRAPH UPSTREAM FROM THIS CONTAINER.

assert(ischar(containerUUID));

G2 = getSubgraph(G, containerUUID);
fcnsG = getFcnsOnlyDigraph(G2);
listOrder = toposort(fcnsG);
orderedPRList(:,1) = fcnsG.Nodes.Name(listOrder);