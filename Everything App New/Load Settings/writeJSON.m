function []=writeJSON(struct, date)

%% PURPOSE: WRITE AN OBJECT ITS SQL TABLE.

global conn;

if exist('date','var')~=1
    date=datetime('now');
end

if isstruct(struct)
    struct.Date_Modified=date;
end

uuid = struct.UUID;

[type, abstractID, instanceID] = deText(uuid);
if isempty(instanceID)
    isInstance = false;
else
    isInstance = true;
end

tablename = getTableName(type, isInstance);
sqlquery = struct2SQL(tablename, struct);
exec(conn, sqlquery);