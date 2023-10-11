function [data]=loadJSON(uuid)

%% PURPOSE: GET ALL COLUMNS OF ONE OBJECT FROM THE SQL DATABASE.

tablename = getTableName(uuid);
sqlquery = ['SELECT * FROM ' tablename ' WHERE UUID = ''' uuid ''';'];
data = fetchQuery(sqlquery,'char');