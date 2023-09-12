function [names] = getName(uuids, isInstance)

%% PURPOSE: CONVERT UUID TO HUMAN READABLE NAME
% NOTE: In the future, can check if there's any duplicate UUID's to speed
% this function up.

global conn;

if isempty(uuids)
    names = {};
    return;
end

if exist('isInstance','var')~=1
    isInstance = true;
end

makeChar = false;
if ~iscell(uuids)
    makeChar = true;
    uuids = {uuids};
end

bool = isUUID(uuids);
if ~bool
    disp('Not UUIDs!');
    names = {};
    return;
end

[types,~,instanceIDs] = deText(uuids);
uniqueTypes = unique(types,'stable');

names = cell(length(types),1);
for i=1:length(uniqueTypes)
    isInstance = true;
    idx = find(contains(types,uniqueTypes{i}));
    if isempty(instanceIDs{idx(1)})
        isInstance = false;
    end
    tablename = getTableName(uniqueTypes{i}, isInstance);
    sqlquery = ['SELECT UUID, Name FROM ' tablename];
    t = fetch(conn, sqlquery);            
    t = table2MyStruct(t);

    if isempty(fieldnames(t))
        continue;
    end

    if isempty(t.UUID)
        continue;
    end
    if ~iscell(t.UUID)
        t.UUID = {t.UUID};
        t.Name = {t.Name};
    end
    for j=1:length(uuids)
        uuid = uuids{j};        
        nameIdx = ismember(t.UUID, uuid); % Where in the object list the UUID's & names are.
        name = t.Name(nameIdx);
        if ~isempty(name)
            names(j,1) = name;
        end
    end
end

if makeChar
    names = char(names);
end