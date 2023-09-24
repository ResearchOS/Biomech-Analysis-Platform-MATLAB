function [orderedEdges]=orderedList2Struct(G)

%% PURPOSE: CONVERT THE GRAPH TO AN ORDERED LIST OF EDGES.

if isempty(G)
    orderedEdges = cell(0,2);
    return;
end

% Point away from AN so AN is first.
% order = toposort(G);

nodes = G.Nodes.Name; % Nodes are topologically sorted.
edges = G.Edges.EndNodes;

%% Get the node orders
% orders = NaN(size(edges));

% Lower number is an earlier node. AN is last node.
flippedNodes = flip(nodes);

% The order of the parent nodes
uniqParents = unique(edges(:,2),'stable');
minIdx = NaN(size(uniqParents));
for i=1:length(uniqParents)
    tmpG = getSubgraph(G, uniqParents{i},'up');
    minIdx(i) = find(ismember(flippedNodes, tmpG.Nodes.Name),1,'first');    
end
[~,k] = sort(minIdx);
sortedUniqParents = uniqParents(k); % The order that the right column should be in.

% The order of the children nodes within each parent.
orderedEdges = cell(0,2);
for i=1:length(sortedUniqParents)
    parent = sortedUniqParents{i};
    childrenIdx = ismember(edges(:,2),parent);
    children = edges(childrenIdx,1);
    % tmpG = getSubgraph(G, children, 'up');
    [a,b,c] = intersect(flippedNodes, children);
    % idx = find(ismember(flippedNodes, children));
    sortedChildren = children(c);
    orderedEdges = [orderedEdges; [sortedChildren repmat(parent,length(sortedChildren),1)]];
end
