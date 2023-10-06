function [uuids]=getInstances(uuid)

%% PURPOSE: RETURN ALL INSTANCES OF AN ABSTRACT OBJECT. IF INSTANCE OBJECT PASSED IN, RETURNS ITSELF.

[type, abstractID, instanceID] = deText(uuid);

% Passed in instance object, returns itself.
if ~isempty(instanceID)
    uuids = uuid;
    return;
end

tablename = getTableName(type, true);

sqlquery = ['SELECT UUID FROM ' tablename ' WHERE Abstract_UUID = ''' uuid ''';'];
t = fetchQuery(sqlquery);
uuids = t.UUID;