function [sqlquery] = struct2SQL(tablename, struct, type)

%% PURPOSE: RETURN A 'INSERT INTO' OR 'UPDATE' SQL QUERY FOR THE SPECIFIED STRUCT.

if nargin==2
    type = 'UPDATE'; % Default
end

assert(ismember(upper(type),{'INSERT','UPDATE'}));
colTypes = allColTypes();

varNames = fieldnames(struct);

% Convert data types.
varNamesNew = varNames;
for i=1:length(varNames)
    varName = varNames{i};
    for j=1:length(struct)
        var = struct(j).(varName);

        if ismember(varName,colTypes.linkageCols)
            [col1, col2] = getLinkageCols(var);
            data(j).(col1) = ['''' var{1} ''''];
            data(j).(col2) = ['''' var{2} ''''];
            struct(j).(col1) = var{1};
            struct(j).(col2) = var{2};
            % varNamesNew(ismember(varNamesNew,varName)) = [];
            % varNamesNew = [varNamesNew; col1; col2];
            continue;
        elseif ismember(varName,colTypes.numericCols)
            var = num2str(var);
        elseif ismember(varName,colTypes.jsonCols)
            var = jsonencode(var);
        elseif ismember(varName,colTypes.dateCols)
            var = char(var);
        elseif ismissing(var)
            var = '';
        else
            var = char(var);
        end

        assert(ischar(var));        
        data(j).(varName) = ['''' var ''''];
    end

end

varNames = fieldnames(struct); % Now with linkage column headers added.
varNames(ismember(varNames,colTypes.linkageCols)) = []; % Remove linkage col variables (end nodes)

% Put the data into the sql query.
if isequal(type,'UPDATE')
    assert(length(data)==1);
    sqlquery = ['UPDATE ' tablename ' SET '];
    for i=1:length(varNames)
        varName = varNames{i};
        if isequal(varName,'UUID')
            continue;
        end
        sqlquery = [sqlquery varName ' = ' data.(varName) ', '];
    end
    sqlquery = [sqlquery(1:end-2) ' WHERE UUID = ' data.UUID ';'];
end

if isequal(type,'INSERT')
    varNamesStr = '(';
    for i=1:length(varNames)
        varNamesStr = [varNamesStr varNames{i} ', '];
    end
    varNamesStr = [varNamesStr(1:end-2) ')'];
    valsStr = '(';
    for j=1:length(data)
        for i=1:length(varNames)
            var = data(j).(varNames{i});
            assert(ischar(var));
            valsStr = [valsStr var ', '];
        end
        if j<length(data)
            valsStr = [valsStr(1:end-2) '), ('];
        end
    end
    valsStr = [valsStr(1:end-2) ')'];

    sqlquery = ['INSERT INTO ' tablename ' ' varNamesStr ' VALUES ' valsStr ';'];
end