function [data] = table2MyStruct(table)

%% PURPOSE: CONVERT A TABLE FROM SQL TO A STRUCT WITH THE PROPER DATA TYPES

numericCols = {'OutOfDate','IsHardCoded','Num_Header_Rows'};
jsonCols = {'Data_Path','Project_Path','Process_Queue','Tags','LogsheetVar_Params','NamesInCode','Logsheet_Parameters','Data_Parameters','HardCodedValue'};
dateCols = {'Date_Created','Date_Modified'};

varNames = table.Properties.VariableNames;

for i=1:length(varNames)
    varName = varNames{i};
    var = table.(varName);

    if ismember(varName,numericCols)
        var = double(var);
    elseif ismember(varName,jsonCols)
        var = jsondecode(var);
    elseif ismember(varName,dateCols)
        var = datetime(var);
    elseif ismissing(var)
        var = '';
    else
        var = char(var); % String to char
    end

    data.(varName) = var;
end