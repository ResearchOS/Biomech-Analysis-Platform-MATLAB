function [list] = orderDeps(G, src, trg)

%% PURPOSE: GET ALL FUNCTIONS BETWEEN TWO FUNCTIONS, IN ORDER.
% i.e. dependencies are before the functions that depend on them.
% If src exists but not trg: get all functions downstream from the src
% If trg exists but not src: get all functions upstream from the trg

linksFolder = [getCommonPath() filesep 'Linkages'];
linksFile = [linksFolder filesep 'Linkages.json'];
links = loadJSON(linksFile);

warning off;
getG = true;
if exist('src','var')~=1 || isempty(src)
    getG = false;
    src = 'PRZAAAAA_AAA';
    G = addnode(G,src);
    % Get the idx of the processing nodes with no inputs.
%     idxNums = contains(links(:,2),'VR') & contains(links(:,1),{'LG','PR'}) & ismember(links(:,1), G.Nodes.Name) & ~ismember(links(:,2), G.Nodes.Name);
%     noIns = unique(links(idxNums,1),'stable');
%     G = addedge(G,repmat({src},length(noIns),1));
    for i=1:length(G.Nodes.Name)
        if indegree(G,G.Nodes.Name{i})==0 && ~isequal(G.Nodes.Name{i},src)
            G = addedge(G,src, G.Nodes.Name{i});
        end
    end
end

if exist('trg','var')~=1 || isempty(trg)
    getG = false;
    trg = 'PRZZZZZZ_ZZZ';
    G = addnode(G,trg);
    
    % Get the idx of the processing nodes with no outputs.
    for i=1:length(G.Nodes.Name)
        if outdegree(G,G.Nodes.Name{i})==0 && ~isequal(G.Nodes.Name{i},trg)
            G = addedge(G, G.Nodes.Name{i}, trg);
        end
    end
%     idxNums = contains(links(:,1),'VR') & contains(links(:,2),'PR') & ismember(links(:,2), G.Nodes.Name) & ~ismember(links(:,1), G.Nodes.Name); 
%     noOuts = unique(links(idxNums,2),'stable');
%     G = addedge(G,noOuts,repmat({trg},length(noOuts),1));
end
warning on;

if getG
    G = linkageToDigraph('PR');
end

if isempty(G)
    list = {};
    return;
end

[paths, edgepaths] = allpaths(G, src, trg);
initList = {trg};

% Remove the target node from the list.
for i=1:length(paths)
    paths{i}(end) = [];
end

% Get the ordered list.
list = getList(paths);
list = [list; initList];

if isequal(list{1},'PRZAAAAA_AAA')
    list(1) = [];
end

if isequal(list{end},'PRZZZZZZ_ZZZ')
    list(end) = [];
end

end

function [list] = getList(paths)

% Continue until there are no nodes left in any path.
lengths = ones(size(paths)); % Just to make the loop run the first time.
list = {};
while any(lengths>0)

    % Check the last element of each path. If it appears earlier than the
    % end of a list for any path, then don't add it yet. If it doesn't, add
    % it to the list and remove it from that path.
    for i=1:length(paths)

        if isempty(paths{i})
            continue;
        end

        node = paths{i}(end);

        lenFromEndAll = NaN(size(paths));
        for j=1:length(paths)
            idxNum = find(ismember(paths{j},node)==1);
            if isempty(idxNum)
                continue; % This function isn't in this path, so skip it.
            end

            lenFromEndAll(j) = length(paths{j}) - idxNum; % Indicates proximity to the end of the list. 0=end.
        end

        % If this function is not at the end of one of the lists, skip it,
        % because something else still depends on it.
        if any(lenFromEndAll>0)
            continue;
        end

        % This function is not a dependency to any other function, so remove it from the path and add it to the ordered list.
        paths{i}(end) = [];

        % Only add the node to the list if it's not already in there. There
        % will be redundancies because, for example, each path will contain
        % the source node.
        if ~ismember(node, list)
            list = [node; list]; % Because we're working backwards, pre-pend the node to the list.
        end

        lengths(i) = length(paths{i}); % Check the lengths of each path

    end    

end

end