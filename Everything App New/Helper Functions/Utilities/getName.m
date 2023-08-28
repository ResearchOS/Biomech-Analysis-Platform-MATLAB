function [names] = getName(uuids, isInstance)

%% PURPOSE: CONVERT UUID TO HUMAN READABLE NAME
% NOTE: In the future, can check if there's any duplicate UUID's to speed
% this function up.

global conn;

if exist('isInstance','var')~=1
    isInstance = true;
end

if ~iscell(uuids)
    uuids = {uuids};
end

names = {};
types = deText(uuids);
uniqueTypes = unique(types,'stable');

names = cell(length(types),1);
for i=1:length(uniqueTypes)
    tablename = getTableName(uniqueTypes{i}, isInstance);
    sqlquery = ['SELECT UUID, Name FROM ' tablename];
    t = fetch(conn, sqlquery);        
    zIdx = ismember(t.UUID,'ZZZZZZ_ZZZ');
    t(zIdx,:) = [];
    t = table2MyStruct(t);
    if isempty(t.UUID)
        continue;
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