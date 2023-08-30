function [orderedList, listPR_PG_AN] = getRunList(containerUUID)

%% PURPOSE: GET THE LIST OF ITEMS TO RUN IN THE UUID SPECIFIED (ANALYSIS OR PROCESS GROUP)

assert(ischar(containerUUID));

listPR_PG_AN = getUnorderedList(containerUUID); % Returns list with PR, PG, and AN types.

if isempty(listPR_PG_AN)
    orderedList = {};
    return;
end

links = loadLinks(listPR_PG_AN); % Convert unordered list of processing functions into a linkage table.
G = linkageToDigraph(links);
orderedList = orderDeps(G,'full'); % All PR. Need to convert this to parent objects.

inListIdx = ismember(orderedList(:,1),listPR_PG_AN(:,1)); % Only the PR in the current container
orderedList(~inListIdx,:) = [];

end