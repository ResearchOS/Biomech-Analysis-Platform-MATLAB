function uuid = genUUID(class, abstractID, instanceID, name)

uuid='';
abbrev = className2Abbrev(class);

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