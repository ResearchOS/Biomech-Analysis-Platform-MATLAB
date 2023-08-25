function [runList] = getRunList(uuids, list)

%% PURPOSE: GET THE LIST OF ITEMS TO RUN IN THE UUID SPECIFIED (ANALYSIS OR PROCESS GROUP)
% To put any combination of processing functions in order, specify UUIDs as
% a cell array of chars, where each element is a PR or PG UUID.

if exist('initRunList','var')~=1
    list = {};
end

if ~iscell(uuids)
    uuids = {uuids};
end

%% 1. Recursively get the list of all process functions to run.
% Get all of the group & function names in this run list.
for i=1:length(uuids)
    list = getUnorderedList(uuids{i}, list);
end
links = loadLinks(list);

%% 2. Order them with the help of the digraph.
G = linkageToDigraph('full',links);
runList = orderDeps(G,'full');

end

function [list] = getUnorderedList(uuid, list)

global conn;

[type] = deText(uuid);

switch type
    case 'AN'
        sqlquery = ['SELECT AN_PG.PG_ID, AN_PR.PR_ID FROM AN_PG JOIN ON AN_PG.AN_ID = AN_PR.AN_ID WHERE AN_PR.AN_ID = ''' uuid ''';'];
    case 'PG'
        sqlquery = ['SELECT PG_PG.Child_PG_ID, PG_PR.PR_ID FROM PG_PR JOIN PG_PG ON PG_PG.Parent_PG_ID = PG_PR.PG_ID WHERE PG_PG.Parent_PG_ID = ''' uuid ''';'];
    case 'PR'
        sqlquery = ['SELECT UUID FROM Process_Instances WHERE UUID = ''' uuid ''';'];
end
t = fetch(conn, sqlquery);
tList = table2MyStruct(t); % Convert data types from SQL to MATLAB.
fldNames = fieldnames(tList);
for i=1:length(fldNames)
    list = [list; tList.(fldNames{i})];
end
[types] = deText(list);
idx = ~ismember(types,'PR'); % See if any elements are not PR.
if any(idx)
    tmp = list(idx);
    for i=1:length(tmp)
        [list] = getUnorderedList(tmp{i}, list);
    end
end

end