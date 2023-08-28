function [orderedList, listPR_PG_AN] = getRunList(containerUUID)

%% PURPOSE: GET THE LIST OF ITEMS TO RUN IN THE UUID SPECIFIED (ANALYSIS OR PROCESS GROUP)
global conn;

assert(ischar(containerUUID));

[type] = deText(containerUUID);

% Get the groups in this container
if isequal(type,'AN')
    sqlquery = ['SELECT PG_ID FROM AN_PG WHERE AN_ID = ''' containerUUID ''';'];
else
    sqlquery = ['SELECT Child_PG_ID FROM PG_PG WHERE Parent_PG_ID = ''' containerUUID ''';'];
end
listPG = fetch(conn, sqlquery);
listPG = table2MyStruct(listPG);
fldName = fieldnames(listPG);
listPG = listPG.(fldName{1});
if isempty(listPG)
    listPG = {};
end

% Get the processing functions in this container.
if isequal(type,'AN')
    sqlquery = ['SELECT PR_ID FROM AN_PR WHERE AN_ID = ''' containerUUID ''';'];
else
    sqlquery = ['SELECT PR_ID FROM PG_PR WHERE PG_ID = ''' containerUUID ''';'];
end
listPR = fetch(conn, sqlquery);
listPR = table2MyStruct(listPR);
listPR = listPR.PR_ID;
if isempty(listPR)
    listPR = {};
end
if isempty(listPR) && isempty(listPG)
    orderedList = {};
    listPR_PG_AN = {};
    return;
end

listInclContainer = [listPR; listPG]; % The top level groups & functions in the analysis.
listInclContainer(:,2) = {containerUUID}; % Include the container UUID.
listPR_PG_AN = getPRFromPG(listInclContainer(:,1), listInclContainer); % Get all processing functions in the groups.
prIdx = contains(listPR_PG_AN(:,1),'PR'); % All processing functions together (from all groups in current analysis).
listPR_Only = listPR_PG_AN(prIdx,:); % Isolate the rows that have processing functions, not groups in groups.
links = loadLinks(listPR_Only(:,1)); % Convert unordered list of processing functions into a linkage table.
G = linkageToDigraph('PR', links);
orderedList = orderDeps(G,'full'); % All PR. Need to convert this to parent objects.

inListIdx = ismember(orderedList(:,1),listPR_PG_AN(:,1)); % Only the PR in the current container
orderedList(~inListIdx,:) = [];

end