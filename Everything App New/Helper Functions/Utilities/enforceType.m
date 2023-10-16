function [typeVar] = enforceType(var, varName)

%% PURPOSE: ENSURE THAT A VARIABLE IS RETURNED FROM SQL AS THE CORRECT TYPE/FORMAT

colTypes = allColTypes();
colTypeFldNames = fieldnames(colTypes);

%% Determine what type of variable this is:
isChar = true;
for i=1:length(colTypeFldNames)
    colTypeFldName = colTypeFldNames{i};
    if ismember(varName,colTypes.(colTypeFldName))
        isChar = false;
        break;
    end
end

if isChar
    colTypeFldName = 'char';
end

switch colTypeFldName
    case 'char' % type: cell array of chars
        if isstring(var)
            if ~isscalar(var)
                typeVar = cellstr(var);                
            elseif ~ismissing(var)
                typeVar = char(var);                
            elseif ismissing(var)
                typeVar = '';
            end
        elseif iscell(var)
            typeVar = var;
            assert(all(cellfun(@ischar, typeVar)));
        end
        assert(ischar(typeVar) || iscell(typeVar));
    case 'numericCols' % type: double
        typeVar = double(var);
        assert(isnumeric(typeVar));
    case 'jsonCols' % type: struct
        if isstring(var) && ~isscalar(var)
            var = cellstr(var);
            typeVar = cell(size(var));
            for i=1:length(var)
                typeVar{i} = jsondecode(var{i});
            end
        else
            try
                typeVar = jsondecode(var);
                if ~isstring(var)
                    assert(isstruct(typeVar) || iscell(typeVar));
                else
                    % if isstruct(typeVar)
                    %     typeVar = {typeVar};
                    % end
                    % assert(ischar(typeVar));
                end
            catch
                typeVar = {};
            end
        end
    case 'linkageCols' % type: Nx2 matrix (or table?)
        typeVar = var;
        assert(iscell(typeVar));
        assert(size(typeVar,2)==2);
    case 'dateCols' % type: datetime
        typeVar = datetime(var);
        assert(isdatetime(typeVar));
end