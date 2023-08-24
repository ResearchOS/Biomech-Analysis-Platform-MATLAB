function [tablename] = getTableName(class, isInstance)

%% PURPOSE: RETURN THE SQL TABLE NAME FOR THE CURRENT CLASS

if nargin==1
    isInstance = false;
end

if length(class)==2
    class = className2Abbrev(class, true);
end

class = makeClassPlural(class);

if isInstance
    suffix = 'Instances';
else
    suffix = 'Abstract';
end

tablename = [class '_' suffix];