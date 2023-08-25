function [links]=loadLinks(list)

%% PURPOSE: JOIN AND LOAD THE LINKAGE TABLES RESPONSIBLE FOR CONNECTING THE PROCESSING FUNCTIONS TO EACH OTHER VIA VARIABLES.
global conn;

sqlquery = ['SELECT VR_PR.PR_ID PR_UUID_In, VR_PR.VR_ID VR_UUID, PR_VR.PR_ID PR_UUID_Out FROM VR_PR INNER JOIN PR_VR ON VR_PR.VR_ID = PR_VR.VR_ID;'];
allLinks = fetch(conn, sqlquery);
allLinks(1,:) = [];

links = table2cell(allLinks);

idx = ismember(links(:,1),list) & ismember(links(:,2),list);

links(~idx,:) = [];