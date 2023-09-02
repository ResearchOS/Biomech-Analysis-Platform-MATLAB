function [data] = table2MyStruct(table,format)

%% PURPOSE: CONVERT A TABLE FROM SQL TO A STRUCT WITH THE PROPER DATA TYPES
% format: 'cell' or 'struct'. Struct means vector struct, cell means scalar
% struct with cell arrays.

if nargin==1
    format = 'cell';
end

numericCols = {'OutOfDate','IsHardCoded','Num_Header_Rows'};
jsonCols = {'Data_Path','Project_Path','Process_Queue','Tags','LogsheetVar_Params','Logsheet_Path',...
    'Logsheet_Parameters','Data_Parameters','HardCodedValue','ST_ID','InputVariablesNamesInCode','OutputVariablesNamesInCode','SpecifyTrials',...
    'Current_View','InclNodes'};
dateCols = {'Date_Created','Date_Modified','Date_Last_Ran'};

varNames = table.Properties.VariableNames;

for i=1:length(varNames)
    varName = varNames{i};
    var = table.(varName);

    if ismissing(var)
        var = '';
    elseif ismember(varName,numericCols)
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
    else
        if isstring(var) && isscalar(var)
            var = char(var); % String to char
        elseif isstring(var)
            var = cellstr(var); % String to cell array of chars
        end
    end

    if isequal(format,'cell')
        data.(varName) = var; 
    else
        for j=1:length(var)
            data(j).(varName) = var{j};
        end
    end
end