function [data] = table2MyStruct(table)

%% PURPOSE: CONVERT A TABLE FROM SQL TO A STRUCT WITH THE PROPER DATA TYPES

numericCols = {'OutOfDate','IsHardCoded','Num_Header_Rows'};
jsonCols = {'Data_Path','Project_Path','Process_Queue','Tags','LogsheetVar_Params',...
    'Logsheet_Parameters','Data_Parameters','HardCodedValue','ST_ID','InputVariablesNamesInCode','OutputVariablesNamesInCode'};
dateCols = {'Date_Created','Date_Modified','Date_Last_Ran'};

varNames = table.Properties.VariableNames;

for i=1:length(varNames)
    varName = varNames{i};
    var = table.(varName);

    if ismember(varName,numericCols)
        var = double(var);
    elseif ismember(varName,jsonCols)
        if ~isequal(var,'NULL')  
            if isscalar(var) && (isstring(var) || ischar(var))                
                var = jsondecode(var);
            else
                tmp = cell(size(var));
                for j = 1:length(var)
                    if isequal(var(j),'NULL')
                        tmp{j} = 'NULL';
                    else
                        tmp{j} = jsondecode(var(j));
                    end
                end
                var = tmp;
            end
        end
    elseif ismember(varName,dateCols)
        var = datetime(var);
    elseif ismissing(var)
        var = '';
    else
        if isstring(var) && isscalar(var)
            var = char(var); % String to char
        elseif isstring(var)
            var = cellstr(var); % String to cell array of chars
        end
    end

    data.(varName) = var;
end