function uuid = genUUID(class, abstractID, instanceID, name)

uuid='';
if ischar(class) && length(class)==2
    abbrev = class;
else
    abbrev = className2Abbrev(class);
end

if nargin<=1
    return;
end

if nargin<3
    instanceID='';
end

if ~isempty(abstractID) && isempty(instanceID)
    uuid = [abbrev abstractID];
    return;
end

if ~isempty(instanceID)
    uuid = [abbrev abstractID '_' instanceID];
    return;
end

% What do I do if they include the name?