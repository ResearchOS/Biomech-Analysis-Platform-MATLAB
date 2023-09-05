function []=saveClass(classStruct)

%% PURPOSE: SAVE A CLASS INSTANCE TO A NEW ROW (USING INSERT STATEMENT)
global conn;

uuid = classStruct.UUID;
[type,abstractID,instanceID]=deText(uuid);

if ~isempty(instanceID)
    suffix = 'Instances';
else
    suffix = 'Abstract';
end

class = className2Abbrev(type);
classPlural = makeClassPlural(class);
tablename = [classPlural '_' suffix];

sqlquery = struct2SQL(tablename, classStruct, 'INSERT');
execute(conn, sqlquery);