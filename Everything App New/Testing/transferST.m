function [] = transferST()

%% PURPOSE: PUT THE ST IN THE NEW PR_ST_AN TABLE.

global conn;

sqlquery = ['SELECT UUID, SpecifyTrials FROM Process_Instances'];
t = fetchQuery(sqlquery);

allST = t.SpecifyTrials;
uuids = t.UUID;

Current_Analysis = getCurrent('Current_Analysis');
for i=1:length(allST)
    for j=1:length(allST{i})

        sqlquery = ['INSERT INTO PR_ST_AN (PR_ID, ST_ID, AN_ID) VALUES (''' uuids{i} ''', ''' allST{i}{j} ''', ''' Current_Analysis ''');'];
        execute(conn, sqlquery);

    end
end