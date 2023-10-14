function []=deleteObject(uuid)

%% PURPOSE: DELETE THE SPECIFIED OBJECT. ALSO REMOVES ALL LINKS TO IT.

global globalG conn;

globalG = rmnode(globalG, uuid);

assert(isUUID(uuid));
type = deText(uuid);
tablename = getTableName(type, isInstance(uuid));

sqlquery = ['DELETE FROM ' tablename ' WHERE UUID = ''' uuid ''';'];
execute(conn, sqlquery);