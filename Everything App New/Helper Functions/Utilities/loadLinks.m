function [links]=loadLinks(list)

%% PURPOSE: JOIN AND LOAD THE LINKAGE TABLES RESPONSIBLE FOR CONNECTING THE PROCESSING FUNCTIONS TO EACH OTHER VIA VARIABLES.
global conn;

% Only the contained UUIDs ('PR') should be loaded, because only they are in the PR_VR & VR_PR tables.
if size(list,2)==2
    list = list(:,1);
end

if isempty(list)
    list = '';
end

prIdx = contains(list,'PR'); % All processing functions together (from all groups in current analysis).
list = list(prIdx,:); % Isolate the rows that have processing functions, not groups in groups.

% Output vars, process function, input var
sqlquery = ['SELECT PR_VR.PR_ID PR_UUID_Out, VR_PR.VR_ID VR_UUID, VR_PR.PR_ID PR_UUID_In FROM VR_PR INNER JOIN PR_VR ON VR_PR.VR_ID = PR_VR.VR_ID;'];
allLinks = fetch(conn, sqlquery);
links = cellstr(table2cell(allLinks));
zIdx = ismember(links(:,1),'ZZZZZZ_ZZZ');
links(zIdx,:) = [];

idx = ismember(links(:,1),list) | ismember(links(:,3),list);

links(~idx,:) = [];