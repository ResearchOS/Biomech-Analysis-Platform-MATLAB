function [list] = orderDeps(src, trg)

%% PURPOSE: GET ALL FUNCTIONS BETWEEN TWO FUNCTIONS, IN ORDER.
% i.e. dependencies are before the functions that depend on them.

G = linkageToDigraph();

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

end

function [list] = getList(paths)

% Continue until there are no nodes left in any path.
lengths = ones(size(paths)); % Just to make the loop run the first time.
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