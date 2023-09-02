function [tablename] = getTableName(class, isInstance)

%% PURPOSE: RETURN THE SQL TABLE NAME FOR THE CURRENT CLASS

if nargin==1
    isInstance = false;
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

if isChar
    tablename = tablename{1};
end