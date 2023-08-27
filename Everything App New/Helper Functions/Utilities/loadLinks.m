function [links]=loadLinks(list)

%% PURPOSE: JOIN AND LOAD THE LINKAGE TABLES RESPONSIBLE FOR CONNECTING THE PROCESSING FUNCTIONS TO EACH OTHER VIA VARIABLES.
global conn;

if isempty(list)
    list = '';
end

% Output vars, process function, input var
sqlquery = ['SELECT PR_VR.PR_ID PR_UUID_Out, VR_PR.VR_ID VR_UUID, VR_PR.PR_ID PR_UUID_In FROM VR_PR INNER JOIN PR_VR ON VR_PR.VR_ID = PR_VR.VR_ID;'];
allLinks = fetch(conn, sqlquery);
links = cellstr(table2cell(allLinks));
zIdx = ismember(links(:,1),'ZZZZZZ_ZZZ');
links(zIdx,:) = [];

idx = ismember(links(:,1),list) | ismember(links(:,3),list);

links(~idx,:) = [];