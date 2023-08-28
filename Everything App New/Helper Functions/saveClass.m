function []=saveClass(classStruct, date)

%% PURPOSE: SAVE A CLASS INSTANCE TO A NEW ROW (USING INSERT STATEMENT)
global conn;

uuid = classStruct.UUID;
[type,abstractID,instanceID]=deText(uuid);

if ~isempty(instanceID)
    suffix = 'Instances';
else
    suffix = 'Abstract';
end

class = className2Abbrev(type, true);
class = makeClassPlural(class);
tablename = [class '_' suffix];

sqlquery = struct2SQL(tablename, classStruct, 'INSERT');
execute(conn, sqlquery);