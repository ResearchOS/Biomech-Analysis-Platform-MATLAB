function [list, isCyclic] = orderDeps(G, type, src, trg)

%% PURPOSE: GET ALL FUNCTIONS BETWEEN TWO FUNCTIONS, IN ORDER.
% Type: 
    % 'partial': Nodes are included if any single edge points to that node.
    % 'full': Nodes are included only if all edges come from the source node.
% i.e. dependencies are before the functions that depend on them.
% If src exists but not trg: get all functions downstream from the src
% If trg exists but not src: get all functions upstream from the trg


getG = false;
if ~exist('G','var') || isempty(G)
    getG = true;
end

if getG
    G = linkageToDigraph('PR');
end

if ~exist('src','var') || isempty(src)
    src = '';
end

if ~exist('trg','var') || isempty(trg)
    trg = '';
end

assert(isempty(src) || isempty(trg));

if ismember(src,G.Nodes.Name)
    srcInEdgesIdx = find(ismember(G.Edges.EndNodes(:,2),src));
    G = rmedge(G, srcInEdgesIdx);
end

if ismember(trg,G.Nodes.Name)
    srcOutEdgesIdx = find(ismember(G.Edges.EndNodes(:,1),trg));
    G = rmedge(G, srcOutEdgesIdx);
end

if isempty(G)
    list = {};
    return;
end

%% Try the new algorithm
% https://en.wikipedia.org/wiki/Topological_sorting (Kahn's algorithm)
% L ← Empty list that will contain the sorted elements
% S ← Set of all nodes with no incoming edge
% 
% while S is not empty do
%     remove a node n from S
%     add n to L
%     for each node m with an edge e from n to m do
%         remove edge e from the graph
%         if m has no other incoming edges then
%             insert m into S
% 
% if graph has edges then
%     return error   (graph has at least one cycle)
% else 
%     return L   (a topologically sorted order)
list = {};
noInsIdx = indegree(G,G.Nodes.Name)==0;
if ~any(noInsIdx)
    isCyclic = true; % There is no node with in degree = 0.
    return;
end

srcIdx = ismember(G.Nodes.Name,src);
if any(srcIdx)
    noInsIdx = noInsIdx & srcIdx;
elseif ~isempty(trg) || ~isempty(src) % The specified source node is not connected to anything. Skipped if no source specified.
    if isempty(trg)
        list = {src};
    elseif isempty(src)
        list = {trg};
    end
    return;
end

s = G.Nodes.Name(noInsIdx);  
while ~isempty(s)
    nodeN = s(1);
    s(1) = [];
    list = [list; nodeN];
    % Get the list of edges from nodeN
    edgesOutE = outedges(G, nodeN);
    % Get the list of nodes that these edges go to.
    nodesM = G.Edges.EndNodes(edgesOutE,2);
    nodesM = unique(nodesM,'stable');
    for i=1:length(nodesM)
        nodeM = nodesM(i);
        %         disp(getName(nodeM));
        if isequal(type,'full')
            currNodesEdgesIdx = find(ismember(G.Edges.EndNodes(:,1),nodeN) & ismember(G.Edges.EndNodes(:,2),nodeM)==1);
        elseif isequal(type,'partial')
            currNodesEdgesIdx = find(ismember(G.Edges.EndNodes(:,2),nodeM)==1);
        end
        %         disp(getName(G.Edges.EndNodes(currNodesEdgesIdx,:)));
        G = rmedge(G,currNodesEdgesIdx);
        if indegree(G, nodeM)==0
            s = [s; nodeM];
        end
    end
end

isCyclic = false;
if ~isempty(G.Edges.Name)
    isCyclic = true;
end