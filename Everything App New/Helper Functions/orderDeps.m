function [list] = orderDeps(G, type, src, trg)

%% PURPOSE: GET ALL FUNCTIONS BETWEEN TWO FUNCTIONS, IN ORDER.
% Type: 
    % 'partial': Nodes are included if any single edge points to that node.
    % 'full': Nodes are included only if all edges come from the source node.
% i.e. dependencies are before the functions that depend on them.
% If src exists but not trg: get all functions downstream from the src
% If trg exists but not src: get all functions upstream from the trg


links = loadLinks();

getG = false;
if ~exist('G','var') || isempty(G)
    getG = true;
end

if ~exist('src','var')
    src = {};
end

if ~exist('trg','var')
    trg = {};
end

if ismember(src,G.Nodes.Name)
    srcInEdgesIdx = find(ismember(G.Edges.EndNodes(:,2),src));
    G = rmedge(G, srcInEdgesIdx);
end

if ismember(trg,G.Nodes.Name)
    srcOutEdgesIdx = find(ismember(G.Edges.EndNodes(:,1),trg));
    G = rmedge(G, srcOutEdgesIdx);
end

if getG
    G = linkageToDigraph('PR');
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
noInsIdx = indegree(G,G.Nodes.Name)==0;
srcIdx = ismember(G.Nodes.Name,src);
if any(srcIdx)
    noInsIdx = noInsIdx & srcIdx;
end
list = {};
s = G.Nodes.Name(noInsIdx);
if isequal(type,'full')    
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
            currNodesEdgesIdx = find(ismember(G.Edges.EndNodes(:,1),nodeN) & ismember(G.Edges.EndNodes(:,2),nodeM)==1);
            %         disp(getName(G.Edges.EndNodes(currNodesEdgesIdx,:)));
            G = rmedge(G,currNodesEdgesIdx);
            if indegree(G, nodeM)==0
                s = [nodeM; s];
            end
        end
    end
elseif isequal(type,'partial')
    while ~isempty(s)
        nodeN = s(1);
        s(1) = [];
        list = [list; nodeN];
        % Get the list of edges from nodeN
        edgesOutE = outedges(G, nodeN);
        % Get the list of nodes that these edges go to.
        nodesM = G. Edges.EndNodes(edgesOutE, 2);
        nodesM = unique(nodesM, 'stable');
        for i=1:length(nodesM)
            nodeM = nodesM(i);
            %         disp(getName(nodeM));
            currNodesEdgesIdx = find(ismember(G.Edges.EndNodes(:,1),nodeN) & ismember(G.Edges.EndNodes(:,2),nodeM)==1);
            G = rmedge(G,currNodesEdgesIdx);
            % Always add the node to the list
            s = [nodeM; s];
        end
    end
end








%% Previous algorithm - very slow after a few dozen nodes.
% [paths, edgepaths] = allpaths(G, src, trg);
% initList = {trg};
% 
% % Remove the target node from the list.
% for i=1:length(paths)
%     paths{i}(end) = [];
% end
% 
% % Get the ordered list.
% list = getList(paths);
% list = [list; initList];
% 
% if isequal(list{1},'PRZAAAAA_AAA')
%     list(1) = [];
% end
% 
% if isequal(list{end},'PRZZZZZZ_ZZZ')
%     list(end) = [];
% end
% 
% end
% 
% function [list] = getList(paths)
% 
% % Continue until there are no nodes left in any path.
% lengths = ones(size(paths)); % Just to make the loop run the first time.
% list = {};
% while any(lengths>0)
% 
%     % Check the last element of each path. If it appears earlier than the
%     % end of a list for any path, then don't add it yet. If it doesn't, add
%     % it to the list and remove it from that path.
%     for i=1:length(paths)
% 
%         if isempty(paths{i})
%             continue;
%         end
% 
%         node = paths{i}(end);
% 
%         lenFromEndAll = NaN(size(paths));
%         for j=1:length(paths)
%             idxNum = find(ismember(paths{j},node)==1);
%             if isempty(idxNum)
%                 continue; % This function isn't in this path, so skip it.
%             end
% 
%             lenFromEndAll(j) = length(paths{j}) - idxNum; % Indicates proximity to the end of the list. 0=end.
%         end
% 
%         % If this function is not at the end of one of the lists, skip it,
%         % because something else still depends on it.
%         if any(lenFromEndAll>0)
%             continue;
%         end
% 
%         % This function is not a dependency to any other function, so remove it from the path and add it to the ordered list.
%         paths{i}(end) = [];
% 
%         % Only add the node to the list if it's not already in there. There
%         % will be redundancies because, for example, each path will contain
%         % the source node.
%         if ~ismember(node, list)
%             list = [node; list]; % Because we're working backwards, pre-pend the node to the list.
%         end
% 
%         lengths(i) = length(paths{i}); % Check the lengths of each path
% 
%     end    
% 
% end
% 
% end