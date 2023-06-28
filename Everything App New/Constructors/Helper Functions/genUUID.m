function uuid = genUUID(class, abstractID, instanceID, name)

uuid='';

if nargin<=1    
    return;
end

abbrev = className2Abbrev(class);

if ~isempty(abstractID) && isempty(instanceID)
    uuid = [abbrev abstractID];
    return;
end

if ~isempty(instanceID)
    uuid = [abbrev abstractID '_' instanceID];
    return;
end

% What do I do if they include the name?