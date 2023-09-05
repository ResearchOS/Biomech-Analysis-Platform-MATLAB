function uuids = genUUID(class, abstractID, instanceID, name)

if nargin<=1
    return;
end

if isempty(class)
    class = {};
end

if ~iscell(class)
    class = {class};
end

makeChar = false;
if isempty(abstractID)
    abstractID = {};
end
if ~iscell(abstractID)
    makeChar = true;
    abstractID = {abstractID};
end

if nargin==2 || isempty(instanceID)
    instanceID = {};
end

if ~iscell(instanceID)
    instanceID = {instanceID};
end

uuids = cell(size(abstractID));
for i=1:length(abstractID)

    if ischar(class{i}) && length(class{i})==2
        abbrev = class{i};
    else
        abbrev = className2Abbrev(class{i});
    end    

    if ~isempty(abstractID{i}) && (length(instanceID)<i || isempty(instanceID{i}))
        uuids{i} = [abbrev abstractID{i}];
        continue;
    end

    uuids{i} = [abbrev abstractID{i} '_' instanceID{i}];

end

if makeChar
    uuids = uuids{1};
end

% What do I do if they include the name?