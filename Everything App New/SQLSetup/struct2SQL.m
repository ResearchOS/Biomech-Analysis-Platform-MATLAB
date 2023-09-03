function [sqlquery] = struct2SQL(tablename, struct, type)

%% PURPOSE: RETURN A 'INSERT INTO' OR 'UPDATE' SQL QUERY FOR THE SPECIFIED STRUCT.

if nargin==2
    type = 'UPDATE'; % Default
end

assert(ismember(upper(type),{'INSERT','UPDATE'}));

numericCols = {'OutOfDate','IsHardCoded','Num_Header_Rows'};
jsonCols = {'Data_Path','Project_Path','Process_Queue','Tags','LogsheetVar_Params','Logsheet_Path',...
    'Logsheet_Parameters','Data_Parameters','HardCodedValue','ST_ID','InputVariablesNamesInCode','OutputVariablesNamesInCode','SpecifyTrials',...
    'Current_View','InclNodes'};
dateCols = {'Date_Created','Date_Modified','Date_Last_Ran'};

varNames = fieldnames(struct);

% Convert data types.
for i=1:length(varNames)
    varName = varNames{i};
    for j=1:length(struct)
        var = struct(j).(varName);

        if ismember(varName,numericCols)
            var = num2str(var);
        elseif ismember(varName,jsonCols)
            var = ['''' jsonencode(var) ''''];
        elseif ismember(varName,dateCols)
            var = ['''' char(var) ''''];
        elseif ismissing(var)
            var = '';
        else
            var = ['''' char(var) ''''];
        end

        assert(ischar(var));
        data(j).(varName) = var;
    end

end

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