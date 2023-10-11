function [data] = table2MyStruct(table,format)

%% PURPOSE: CONVERT A TABLE FROM SQL TO A STRUCT WITH THE PROPER DATA TYPES
% format: 'cell' or 'struct'. Struct means vector struct, cell means scalar
% struct with cell arrays.

if nargin==1
    format = 'cell';
end

varNames = table.Properties.VariableNames;

if isempty(table)
    data = struct();
    return;
end

for i=1:length(varNames)
    varName = varNames{i};
    var = table.(varName);

    var = enforceType(var,varName);

    % if isempty(var)
    %     data.(varName) = {};
    %     continue;
    % elseif ismissing(var)
    %     var = '';
    % elseif ismember(varName,numericCols)
    %     var = double(var);
    % elseif ismember(varName,jsonCols)
    %     if ~isequal(var,'NULL')  
    %         if isscalar(var) && (isstring(var) || ischar(var))  
    %             try
    %                 var = jsondecode(var);
    %             catch
    %                 var = ''; % Not initialized properly.                    
    %             end
    %         else
    %             tmp = cell(size(var));
    %             for j = 1:length(var)
    %                 if isequal(var(j),'NULL')
    %                     tmp{j} = 'NULL';
    %                 else
    %                     tmp{j} = jsondecode(var(j));
    %                 end
    %             end
    %             var = tmp;
    %         end
    %     end
    % elseif ismember(varName,dateCols)
    %     var = datetime(var);
    % else
    %     if isstring(var) && isscalar(var)
    %         var = char(var); % String to char
    %     elseif isstring(var)
    %         var = cellstr(var); % String to cell array of chars
    %     end
    % end

    if isequal(format,'cell')
        data.(varName) = var; 
    else
        for j=1:size(var,1)
            if iscell(var) && isscalar(var(j,:))
                data(j).(varName) = var{j};
            elseif ~ischar(var)
                data(j).(varName) = var(j,:);
            else
                data(j).(varName) = var;
                break;
            end
        end
    end
end