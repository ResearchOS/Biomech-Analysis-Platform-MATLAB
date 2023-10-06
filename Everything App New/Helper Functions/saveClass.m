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

if ~isempty(instanceID)
    Name = {classStruct.UUID};
    OutOfDate = classStruct.OutOfDate;
    nodeProps = table(Name, OutOfDate);    
    try
        globalG = addnode(globalG, nodeProps);
    catch e        
        if ~contains(e.message,'Node names must be unique.')
            error(e);
        end
    end
end

sqlquery = struct2SQL(tablename, classStruct, 'INSERT');
execute(conn, sqlquery);