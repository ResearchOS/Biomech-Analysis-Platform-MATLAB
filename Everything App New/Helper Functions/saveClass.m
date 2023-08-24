function []=saveClass(class, classStruct, date)

%% PURPOSE: SAVE A CLASS INSTANCE TO A NEW ROW.
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

colNames = fieldnames(classStruct);
colNamesStr = '(';
for i=1:length(colNames)
    colNamesStr = [colNamesStr colNames{i} ', '];
end
colNamesStr = [colNamesStr(1:end-2) ')'];
valsStr = '(';
for i=1:length(colNames)
    currVar = classStruct.(colNames{i});
    if isa(currVar,'datetime')
        currVar = char(currVar);
    end
    if isa(currVar,'char') || (isa(currVar,'string') && isscalar(currVar))
        currVar = char(currVar);
        valsStr = [valsStr '''' currVar ''', '];
    elseif isnumeric(currVar) || islogical(currVar)
        valsStr = [valsStr num2str(currVar) ', '];
    elseif isstruct(currVar)
        valsStr = [valsStr '''' jsonencode(currVar) ''', '];
    elseif iscell(currVar)
        cellStr = '''';
        for j=1:length(currVar)
            cellStr = [cellStr currVar{j} ', '];
        end
        cellStr = [cellStr ''''];
        valsStr = [valsStr '''' cellStr ''', '];
    else
        error('What is this?');
    end
end

valsStr = [valsStr(1:end-2) ')'];

sqlquery = ['INSERT INTO ' tablename ' ' colNamesStr ' VALUES ' valsStr ';'];
execute(conn, sqlquery);