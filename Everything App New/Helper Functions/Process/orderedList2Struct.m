function [orderedEdges]=orderedList2Struct(G)

%% PURPOSE: CONVERT THE GRAPH TO AN ORDERED LIST OF EDGES.

global globalG;

if isempty(G)
    orderedEdges = cell(0,2);
    return;
end

% 1. Order the node names.
order = toposort(G);
orderedNodes = G.Nodes.Name(order);

% 2. Order the edges by where the left side appears in the toposort.
edges = G.Edges.EndNodes;
orderedEdges = cell(size(edges));
count = 1; 
for i=1:length(orderedNodes)
    nodeIdx = ismember(G.Edges.EndNodes(:,1),orderedNodes{i});
    currEdges = G.Edges.EndNodes(nodeIdx,:);
    orderedEdges(count:count-1+sum(nodeIdx),:) = currEdges;
    count = count+sum(nodeIdx);    

end

% 3. Get rid of unwanted object types. Important that this is
% here to get the correct results for fillAnalysisUITree
rmIdx = contains(orderedEdges(:,1),{'VR','VW','LG'}) | contains(orderedEdges(:,2),{'VR','VW','LG'});
orderedEdges(rmIdx,:) = [];

% Reorder the children objects (that are also parents) that are out of
% order, because they're children of the top-level node?
parentObjs = unique(orderedEdges(:,2),'stable');
parentObjsAsChildIdx = ismember(orderedEdges(:,1),parentObjs);
parentObjsAsChildren = orderedEdges(parentObjsAsChildIdx,1); % Exclude top level node.
[~,orderedParentObjs] = makeSameOrder(parentObjs, parentObjsAsChildren); % Reorder to be in the same order.
orderedEdges(parentObjsAsChildIdx) = orderedParentObjs;