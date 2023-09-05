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
    'Current_View','InclNodes','Current_Logsheet','Current_Analysis'};
dateCols = {'Date_Created','Date_Modified','Date_Last_Ran'};

varNames = table.Properties.VariableNames;

if isempty(table)
    data = struct();
    return;
end

for i=1:length(varNames)
    varName = varNames{i};
    var = table.(varName);

    if isempty(var)
        data.(varName) = {};
        continue;
    elseif ismissing(var)
        var = '';
    elseif ismember(varName,numericCols)
        var = double(var);
    elseif ismember(varName,jsonCols)
        if ~isequal(var,'NULL')  
            if isscalar(var) && (isstring(var) || ischar(var))  
                try
                    var = jsondecode(var);
                catch
                    var = ''; % Not initialized properly.                    
                end
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
            if iscell(var)
                data(j).(varName) = var{j};
            else
                data(j).(varName) = var(j);
            end
        end
    end
end