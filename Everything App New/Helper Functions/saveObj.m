function []=saveObj(classStruct, type)

%% PURPOSE: SAVE A CLASS INSTANCE TO A NEW ROW (USING INSERT STATEMENT)
global conn globalG;

if nargin==1
    type = 'INSERT';
end

assert(ismember(type,{'INSERT','UPDATE'}));

uuid = classStruct.UUID;
assert(isUUID(uuid));
[abbrev,abstractID,instanceID]=deText(uuid);

if ~isempty(instanceID)
    suffix = 'Instances';
else
    suffix = 'Abstract';
end

class = className2Abbrev(abbrev);
classPlural = makeClassPlural(class);
tablename = [classPlural '_' suffix];

try
    sqlquery = struct2SQL(tablename, classStruct, type);
    execute(conn, sqlquery);
catch e
    error('What happened with SQL?!');
end

if isempty(instanceID)
    return;
end

Name = {classStruct.UUID};
OutOfDate = classStruct.OutOfDate;

if isequal(type,'UPDATE')
    idx = ismember(globalG.Nodes.Name, Name);
    assert(sum(idx)==1);
    globalG.Nodes.OutOfDate(idx) = OutOfDate;
end

%% Insert the instance into the digraph.
nodeProps = table(Name, OutOfDate);

try
    globalG = addnode(globalG, nodeProps);
catch e        
    if ~contains(e.message,'Node names must be unique.')
        error(e);
    end
end

