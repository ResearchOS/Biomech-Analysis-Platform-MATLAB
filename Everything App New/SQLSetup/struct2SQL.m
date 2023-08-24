function [sqlquery] = struct2SQL(tablename, struct, type)

%% PURPOSE: RETURN A 'INSERT INTO' OR 'UPDATE' SQL QUERY FOR THE SPECIFIED STRUCT.

if nargin==2
    type = 'UPDATE'; % Default
end

assert(ismember(upper(type),{'INSERT','UPDATE'}));

numericCols = {'OutOfDate','IsHardCoded','Num_Header_Rows'};
jsonCols = {'Data_Path','Project_Path','Process_Queue','Tags','LogsheetVar_Params','NamesInCode','Logsheet_Parameters','Data_Parameters','HardCodedValue'};
dateCols = {'Date_Created','Date_Modified'};

varNames = fieldnames(struct);

% Convert data types.
for i=1:length(varNames)
    varName = varNames{i};
    var = struct.(varName);

    if ismember(varName,numericCols)

    elseif ismember(varName,jsonCols)
        var = jsonencode(var);
    elseif ismember(varName,dateCols)
        var = char(var);
    elseif ismissing(var)
        var = '';
    else
        var = char(var);
    end

    data.(varName) = var;

end

% Put the data into the sql query.
if isequal(type,'UPDATE')

end

if isequal(type,'INSERT')
    varNamesStr = '(';
    for i=1:length(varNames)
        varNamesStr = [varNamesStr varNames{i} ', '];
    end
    varNamesStr = [varNamesStr(1:end-2) ')'];
    valsStr = '(';
    for i=1:length(varNames)
        var = struct.(varNames{i});
        valsStr = [valsStr var ', '];
    end
    valsStr = [valsStr(1:end-2) ')'];

    sqlquery = ['INSERT INTO ' tableName ' ' varNamesStr ' VALUES ' valsStr ';'];
end