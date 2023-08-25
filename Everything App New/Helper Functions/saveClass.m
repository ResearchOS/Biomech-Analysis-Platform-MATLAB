function []=saveClass(class, classStruct, date)

%% PURPOSE: SAVE A CLASS INSTANCE TO A NEW ROW (USING INSERT STATEMENT)
global conn;

uuid = classStruct.UUID;
[~,abstractID,instanceID]=deText(uuid);

if ~isempty(instanceID)
    suffix = 'Instances';
else
    suffix = 'Abstract';
end

class = makeClassPlural(class);
tablename = [class '_' suffix];

sqlquery = struct2SQL(tablename, classStruct, 'INSERT');
execute(conn, sqlquery);