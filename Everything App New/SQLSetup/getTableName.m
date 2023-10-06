function [tablename] = getTableName(class, isInstance)

%% PURPOSE: RETURN THE SQL TABLE NAME FOR THE CURRENT CLASS
% Option 1: Input UUID as a char or cell array to get object tables.
% Option 2: Input two cell char or cell arrays of UUID's to get the linkage
% tables.

if nargin==1 || islogical(isInstance)
    if nargin==1
        assert(all(isUUID(class)));
        isInstance = true;
        [class, ~, instanceID] = deText(class);
        if isempty(instanceID)
            isInstance = false;
        end
    end

    if isInstance
        suffix = 'Instances';
    else
        suffix = 'Abstract';
    end

    isChar = false;
    if ischar(class)
        isChar = true;
        class = {class};
    end

    tablename = cell(size(class));
    for i=1:length(class)
        currClass = class{i};

        if length(currClass)==2
            currClass = className2Abbrev(currClass);
        end

        currClass = makeClassPlural(currClass);

        tablename{i} = [currClass '_' suffix];

    end
end

if nargin==2 && ~islogical(isInstance)
    isChar = false;
    if ischar(class)
        isChar = true;
        sourceType = {class};
        targetType = {isInstance};        
    else
        sourceType = class;
        targetType = isInstance;
    end

    clear class isInstance;

    tablename = cell(size(sourceType));
    for i=1:length(sourceType)
        source = sourceType{i};
        target = targetType{i};

        tablename{i} = [source '_' target];       

    end

end

if isChar
    tablename = tablename{1};
end
