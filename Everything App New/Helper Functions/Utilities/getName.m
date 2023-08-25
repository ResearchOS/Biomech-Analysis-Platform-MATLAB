function [names] = getName(uuids, isInstance)

%% PURPOSE: CONVERT UUID TO HUMAN READABLE NAME
% NOTE: In the future, can check if there's any duplicate UUID's to speed
% this function up.

global conn;

if exist('isInstance','var')~=1
    isInstance = true;
end

types = deText(uuids);
uniqueTypes = unique(types,'stable');

names = cell(size(types));
for i=1:length(uniqueTypes)
    tablename = getTableName(types{i}, isInstance);
    sqlquery = ['SELECT UUID, Name FROM ' tablename];
    t = fetch(conn, sqlquery);
    t = table2MyStruct(t);
    uuidIdx = ismember(uuids, t.UUID); % Where in the original list the UUID's are.
    names{uuidIdx} = t.Name;
end

return;

beChar = false;
if ischar(uuids)
    beChar = true;
    uuids = {uuids};
end

[m, n] = size(uuids);
uuids = reshape(uuids,m*n,1);

names = cell(size(uuids));
for i=1:length(uuids)
    uuid = uuids{i};
    if isempty(uuid)
        names{i}='';
        continue;
    end
    struct = loadJSON(uuid);

    names{i} = struct.Text;
end

names = reshape(names,m,n);

if beChar
    names = names{1};
end