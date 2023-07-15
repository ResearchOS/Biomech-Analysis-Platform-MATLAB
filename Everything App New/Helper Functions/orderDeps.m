function [list] = orderDeps(src, trg)

%% PURPOSE: GET ALL FUNCTIONS BETWEEN TWO FUNCTIONS

G = linkageToDigraph();

if isempty(G)
    list = {};
    return;
end

[paths, edgepaths] = allpaths(G);
initList = {trg};
% Remove the target node from the list.
for i=1:length(paths)
    paths{i}(end) = [];
end
list = getList(paths);
list = [list; initList];

end

function [list] = getList(paths)

for i=1:length(paths)

    node = paths{i}(end);    

    lenFromEndAll = NaN(size(paths));
    for j=1:length(paths)
        idxNum = find(ismember(paths{j})==1);
        if ~isempty(idxNum)
            lenFromEndAll(j) = length(paths{j}) - idxNum;
        end
    end

    % If this function is not at the end of one of the lists, skip it.
    if any(lenFromEndAll>0)
        continue;
    end

    paths{i}(end) = [];

    list = [node; list];

end

end