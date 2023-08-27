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

listInclContainer = [listPR; listPG]; % The top level groups & functions in the analysis.
listInclContainer(:,2) = {containerUUID}; % Include the container UUID.
listPR_PG_AN = getPRFromPG(listInclContainer(:,1), listInclContainer); % Get all processing functions in the groups.
prIdx = contains(listPR_PG_AN(:,1),'PR'); % All processing functions together (from all groups in current analysis).
listPR_Only = listPR_PG_AN(prIdx,:); % Isolate the rows that have processing functions, not groups in groups.
links = loadLinks(listPR_Only(:,1)); % Convert unordered list of processing functions into a linkage table.
G = linkageToDigraph('PR', links);
orderedList = orderDeps(G,'full'); % All PR. Need to convert this to parent objects.

%% Put things into a struct in the order the nodes should be rendered.
% topLevelUUIDsIdx = ismember(listInclContainer(:,2),containerUUID);
% topLevelUUIDs = listInclContainer(topLevelUUIDsIdx);
% nodeStruct = struct();
% for i=1:length(topLevelUUIDs)
%     nodeStruct.(topLevelUUIDs{i}) = struct();
% end
% for i=1:length(topLevelUUIDs)
%     if contains(topLevelUUIDs{i},'PR')
%         continue;
%     end
% end

    
    % containedIdx = ismember(orderedList,i);

end

% function [list] = getUnorderedList(uuid, list)
% 
% global conn;
% 
% [type] = deText(uuid);
% 
% switch type
%     case 'AN'
%         sqlquery = ['SELECT AN_PG.PG_ID, AN_PR.PR_ID FROM AN_PG JOIN ON AN_PG.AN_ID = AN_PR.AN_ID WHERE AN_PR.AN_ID = ''' uuid ''';'];
%     case 'PG'
%         sqlquery = ['SELECT PG_PG.Child_PG_ID, PG_PR.PR_ID FROM PG_PR JOIN PG_PG ON PG_PG.Parent_PG_ID = PG_PR.PG_ID WHERE PG_PG.Parent_PG_ID = ''' uuid ''';'];
%     case 'PR'
%         sqlquery = ['SELECT UUID FROM Process_Instances WHERE UUID = ''' uuid ''';'];
% end
% t = fetch(conn, sqlquery);
% tList = table2MyStruct(t); % Convert data types from SQL to MATLAB.
% fldNames = fieldnames(tList);
% for i=1:length(fldNames)
%     if isempty(tList.(fldNames{i}))
%         tList.(fldNames{i}) = {};
%     end
%     list = [list; tList.(fldNames{i})];
% end
% [types] = deText(list);
% idx = ~ismember(types,'PR'); % See if any elements are not PR.
% if any(idx)
%     tmp = list(idx);
%     for i=1:length(tmp)
%         [list] = getUnorderedList(tmp{i}, list);
%     end
% end
% 
% end