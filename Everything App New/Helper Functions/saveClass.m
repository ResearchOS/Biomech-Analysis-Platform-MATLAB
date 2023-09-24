function []=saveClass(classStruct)

%% PURPOSE: SAVE A CLASS INSTANCE TO A NEW ROW (USING INSERT STATEMENT)
global conn globalG;

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

if ~isempty(instanceID)
    Name = instStruct.UUID;
    OutOfDate = instStruct.OutOfDate;
    nodeProps = table(Name, OutOfDate);
    globalG = addnode(globalG, nodeProps);
end